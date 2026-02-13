import { Router } from "express";
import fs from "fs/promises";
import path from "path";

import { pool } from "../db.js";
import { ensureCabinetAdmin, ensurePlatformAdmin } from "../middleware/authorization.js";
import { provisionClinicDatabase } from "../services/clinic_db_service.js";

const router = Router();

const CABINET_PHOTOS_DIR = path.join(process.cwd(), "IMAGES", "CABINET");
const ALLOWED_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);

async function ensureCabinetPhotosDir() {
  await fs.mkdir(CABINET_PHOTOS_DIR, { recursive: true });
}

router.get("/by-user/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) {
      return res.status(400).json({ error: "Invalid user id." });
    }

    const result = await pool.query(
      `SELECT
         c.*,
         COALESCE(uc.status, 0) AS status
       FROM cabinet c
       LEFT JOIN users_cabinet uc
         ON uc.id_cabinet = c.id_cabinet
        AND uc.id_user = $1
       LEFT JOIN cabinet_admin ca
         ON ca.id_cabinet = c.id_cabinet
        AND ca.id_user = $1
        AND ca.etat = 1
       WHERE uc.id_user IS NOT NULL OR ca.id_user IS NOT NULL
       ORDER BY c.nom_cabinet ASC`,
      [id],
    );

    return res.json(result.rows);
  } catch (err) {
    console.error("Cabinet create failed:", err);
    return res.status(500).json({ error: err.message });
  }
});

router.get("/search", async (req, res) => {
  try {
    const q = String(req.query.q || "").trim();
    let result;
    if (!q) {
      result = await pool.query(
        `SELECT *
         FROM cabinet
         ORDER BY nom_cabinet ASC`,
      );
    } else {
      const like = `%${q}%`;
      result = await pool.query(
        `SELECT *
         FROM cabinet
         WHERE nom_cabinet ILIKE $1
            OR adresse_cabinet ILIKE $1
            OR specialite_cabinet ILIKE $1
         ORDER BY nom_cabinet ASC`,
        [like],
      );
    }
    return res.json(result.rows);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.get("/pending-platform/:id_admin", async (req, res) => {
  try {
    const adminId = Number(req.params.id_admin);
    if (!Number.isInteger(adminId)) {
      return res.status(400).json({ error: "Invalid admin id." });
    }

    const adminCheck = await ensurePlatformAdmin(adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const result = await pool.query(
      `SELECT
         c.*,
         COALESCE(
           to_jsonb(c)->>'created_at',
           to_jsonb(c)->>'db_created_at'
         ) AS created_at_text,
         creator.fullname AS creator_name
       FROM cabinet c
       LEFT JOIN LATERAL (
         SELECT
           COALESCE(
             NULLIF(TRIM(u.fullname), ''),
             NULLIF(TRIM(u.email), ''),
             CONCAT('ID ', u.id_user::text)
           ) AS fullname
         FROM cabinet_admin ca
         JOIN users u ON u.id_user = ca.id_user
         WHERE ca.id_cabinet = c.id_cabinet
         ORDER BY (ca.etat = 1) DESC, ca.id_user ASC
         LIMIT 1
       ) creator ON TRUE
       WHERE c.etat = 0
       ORDER BY c.id_cabinet DESC`,
    );

    return res.status(200).json(result.rows);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.get("/platform-list/:id_admin", async (req, res) => {
  try {
    const adminId = Number(req.params.id_admin);
    if (!Number.isInteger(adminId)) {
      return res.status(400).json({ error: "Invalid admin id." });
    }

    const adminCheck = await ensurePlatformAdmin(adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const state = String(req.query.state || "pending").trim().toLowerCase();
    const etat =
      state === "approved" ? 1 :
      state === "canceled" ? 2 :
      state === "all" ? null :
      0;
    const q = String(req.query.q || "").trim();
    const like = `%${q}%`;

    const result = await pool.query(
      `SELECT
         c.*,
         COALESCE(
           to_jsonb(c)->>'created_at',
           to_jsonb(c)->>'db_created_at'
         ) AS created_at_text,
         creator.fullname AS creator_name
       FROM cabinet c
       LEFT JOIN LATERAL (
         SELECT
           COALESCE(
             NULLIF(TRIM(u.fullname), ''),
             NULLIF(TRIM(u.email), ''),
             CONCAT('ID ', u.id_user::text)
           ) AS fullname
         FROM cabinet_admin ca
         JOIN users u ON u.id_user = ca.id_user
         WHERE ca.id_cabinet = c.id_cabinet
         ORDER BY (ca.etat = 1) DESC, ca.id_user ASC
         LIMIT 1
       ) creator ON TRUE
       WHERE ($1::int IS NULL OR c.etat = $1)
         AND (
           $2 = ''
           OR c.nom_cabinet ILIKE $3
           OR c.adresse_cabinet ILIKE $3
           OR c.specialite_cabinet ILIKE $3
         )
       ORDER BY c.id_cabinet DESC`,
      [etat, q, like],
    );

    return res.status(200).json(result.rows);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.post("/assign", async (req, res) => {
  try {
    const { id_user, id_cabinet, type_access = 1 } = req.body || {};
    const userId = Number(id_user);
    const cabinetId = Number(id_cabinet);
    if (!Number.isInteger(userId) || !Number.isInteger(cabinetId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    const cabinetCheck = await pool.query(
      "SELECT etat FROM cabinet WHERE id_cabinet = $1 LIMIT 1",
      [cabinetId],
    );
    if (cabinetCheck.rowCount === 0) {
      return res.status(404).json({ error: "Clinic not found." });
    }
    if (Number(cabinetCheck.rows[0].etat) !== 1) {
      return res.status(403).json({ error: "Clinic is not validated yet." });
    }

    await pool.query(
      `INSERT INTO users_cabinet (id_user, id_cabinet, type_access, status, requested_at, approved_at, approved_by)
       VALUES ($1, $2, $3, $4, NOW(), CASE WHEN $4 = 1 THEN NOW() ELSE NULL END, CASE WHEN $4 = 1 THEN $1 ELSE NULL END)
       ON CONFLICT (id_cabinet, id_user)
       DO UPDATE SET
         type_access = EXCLUDED.type_access,
         status = EXCLUDED.status,
         requested_at = NOW(),
         approved_at = CASE WHEN EXCLUDED.status = 1 THEN NOW() ELSE users_cabinet.approved_at END,
         approved_by = CASE WHEN EXCLUDED.status = 1 THEN EXCLUDED.id_user ELSE users_cabinet.approved_by END`,
      [userId, cabinetId, type_access, 0],
    );

    return res.status(201).json({ ok: true, status: "pending" });
  } catch (err) {
    if (err && err.code === "23505") {
      return res.status(409).json({ error: "Already assigned." });
    }
    return res.status(500).json({ error: err.message });
  }
});

router.post("/approve", async (req, res) => {
  try {
    const { id_admin, id_user, id_cabinet } = req.body || {};
    const adminId = Number(id_admin);
    const userId = Number(id_user);
    const cabinetId = Number(id_cabinet);
    if (
      !Number.isInteger(adminId) ||
      !Number.isInteger(userId) ||
      !Number.isInteger(cabinetId)
    ) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    const adminCheck = await ensureCabinetAdmin(cabinetId, adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const result = await pool.query(
      `UPDATE users_cabinet
       SET status = 1,
           approved_at = NOW(),
           approved_by = $3,
           denied_at = NULL,
           denied_by = NULL
       WHERE id_user = $1 AND id_cabinet = $2
       RETURNING *`,
      [userId, cabinetId, adminId],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Request not found." });
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.post("/reject", async (req, res) => {
  try {
    const { id_admin, id_user, id_cabinet } = req.body || {};
    const adminId = Number(id_admin);
    const userId = Number(id_user);
    const cabinetId = Number(id_cabinet);
    if (
      !Number.isInteger(adminId) ||
      !Number.isInteger(userId) ||
      !Number.isInteger(cabinetId)
    ) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    const adminCheck = await ensureCabinetAdmin(cabinetId, adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const result = await pool.query(
      `UPDATE users_cabinet
       SET status = 2,
           denied_at = NOW(),
           denied_by = $3,
           approved_at = NULL,
           approved_by = NULL
       WHERE id_user = $1 AND id_cabinet = $2
       RETURNING *`,
      [userId, cabinetId, adminId],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Request not found." });
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.post("/unassign", async (req, res) => {
  try {
    const { id_user, id_cabinet } = req.body || {};
    const userId = Number(id_user);
    const cabinetId = Number(id_cabinet);
    if (!Number.isInteger(userId) || !Number.isInteger(cabinetId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    const adminCheck = await pool.query(
      `SELECT 1
       FROM cabinet_admin
       WHERE id_cabinet = $1 AND id_user = $2 AND etat = 1
       LIMIT 1`,
      [cabinetId, userId],
    );
    if (adminCheck.rowCount > 0) {
      const adminsCount = await pool.query(
        `SELECT COUNT(*)::int AS total
         FROM cabinet_admin
         WHERE id_cabinet = $1 AND etat = 1`,
        [cabinetId],
      );
      const totalAdmins = adminsCount.rows[0]?.total ?? 0;
      if (totalAdmins <= 1) {
        return res.status(409).json({
          error: "Cannot remove affiliation: this clinic needs at least one admin.",
          code: "LAST_ADMIN",
        });
      }
    }

    const result = await pool.query(
      "DELETE FROM users_cabinet WHERE id_user = $1 AND id_cabinet = $2",
      [userId, cabinetId],
    );

    await pool.query(
      "DELETE FROM cabinet_admin WHERE id_user = $1 AND id_cabinet = $2",
      [userId, cabinetId],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Assignment not found." });
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.post("/validate", async (req, res) => {
  const client = await pool.connect();
  try {
    const { id_admin, id_cabinet } = req.body || {};
    const adminId = Number(id_admin);
    const cabinetId = Number(id_cabinet);
    if (!Number.isInteger(adminId) || !Number.isInteger(cabinetId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    const adminCheck = await ensurePlatformAdmin(adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    await client.query("BEGIN");

    const cabinetResult = await client.query(
      `UPDATE cabinet
       SET etat = 1
       WHERE id_cabinet = $1
       RETURNING id_cabinet`,
      [cabinetId],
    );
    if (cabinetResult.rowCount === 0) {
      await client.query("ROLLBACK");
      return res.status(404).json({ error: "Clinic not found." });
    }

    const admins = await client.query(
      `SELECT id_user
       FROM cabinet_admin
       WHERE id_cabinet = $1 AND etat = 1`,
      [cabinetId],
    );

    for (const row of admins.rows) {
      const adminUserId = Number(row.id_user);
      if (!Number.isInteger(adminUserId)) {
        continue;
      }
      await client.query(
        `INSERT INTO users_cabinet (
           id_user,
           id_cabinet,
           type_access,
           status,
           requested_at,
           approved_at,
           approved_by
         )
         VALUES ($1, $2, 1, 1, NOW(), NOW(), $3)
         ON CONFLICT (id_cabinet, id_user)
         DO UPDATE SET
           status = 1,
           approved_at = NOW(),
           approved_by = $3`,
        [adminUserId, cabinetId, adminId],
      );
    }

    await client.query("COMMIT");
    return res.status(200).json({ ok: true });
  } catch (err) {
    try {
      await client.query("ROLLBACK");
    } catch (_) {}
    return res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

router.post("/reject-clinic", async (req, res) => {
  try {
    const { id_admin, id_cabinet } = req.body || {};
    const adminId = Number(id_admin);
    const cabinetId = Number(id_cabinet);
    if (!Number.isInteger(adminId) || !Number.isInteger(cabinetId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    const adminCheck = await ensurePlatformAdmin(adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const result = await pool.query(
      `UPDATE cabinet
       SET etat = 2
       WHERE id_cabinet = $1
       RETURNING id_cabinet`,
      [cabinetId],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Clinic not found." });
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.post("/", async (req, res) => {
  try {
    const {
      id_user,
      nom_cabinet,
      adresse_cabinet,
      specialite_cabinet,
      phone,
      nationalite_patient_defaut,
      default_currency,
      photo_base64,
      photo_ext,
    } = req.body || {};

    const missing = [];
    if (!id_user) missing.push("id_user");
    if (!nom_cabinet) missing.push("nom_cabinet");
    if (!phone) missing.push("phone");

    if (missing.length > 0) {
      return res
        .status(400)
        .json({ error: `Missing fields: ${missing.join(", ")}` });
    }

    const ownerId = Number(id_user);
    if (!Number.isInteger(ownerId)) {
      return res.status(400).json({ error: "Invalid user id." });
    }

    const ownerCheck = await pool.query(
      "SELECT role FROM users WHERE id_user = $1 LIMIT 1",
      [ownerId],
    );
    if (ownerCheck.rowCount === 0) {
      return res.status(404).json({ error: "User not found." });
    }
    if (Number(ownerCheck.rows[0].role) !== 1) {
      return res.status(403).json({ error: "Only doctors can create clinics." });
    }

    const nameCheck = await pool.query(
      "SELECT 1 FROM cabinet WHERE LOWER(nom_cabinet) = LOWER($1) LIMIT 1",
      [nom_cabinet.trim()],
    );
    if (nameCheck.rowCount > 0) {
      return res.status(409).json({ error: "Cabinet name already exists." });
    }

    const rawNationality = nationalite_patient_defaut;
    const nationalityValue =
      rawNationality === null || rawNationality === undefined || rawNationality === ""
        ? null
        : Number.isInteger(Number(rawNationality))
          ? Number(rawNationality)
          : null;

    const created = await pool.query(
      `INSERT INTO cabinet (
         nom_cabinet,
         adresse_cabinet,
         specialite_cabinet,
         phone,
         nationalite_patient_defaut,
         default_currency,
         photo_url,
         db_status,
         etat
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7, 0, 0)
       RETURNING *`,
      [
        nom_cabinet,
        adresse_cabinet && String(adresse_cabinet).trim().length > 0
          ? adresse_cabinet
          : null,
        specialite_cabinet && String(specialite_cabinet).trim().length > 0
          ? specialite_cabinet
          : null,
        phone,
        nationalityValue,
        (default_currency && String(default_currency).trim().length > 0
          ? String(default_currency).trim().toUpperCase()
          : "DZD"),
        "",
      ],
    );

    let cabinet = created.rows[0];

    try {
      const dbName = await provisionClinicDatabase(cabinet.id_cabinet);
      const dbUpdated = await pool.query(
        `UPDATE cabinet
         SET db_name = $1,
             db_status = 1,
             db_created_at = NOW(),
             db_last_error = NULL
         WHERE id_cabinet = $2
         RETURNING *`,
        [dbName, cabinet.id_cabinet],
      );
      cabinet = dbUpdated.rows[0];
    } catch (dbErr) {
      await pool.query(
        `UPDATE cabinet
         SET db_status = 2,
             db_last_error = $2
         WHERE id_cabinet = $1`,
        [cabinet.id_cabinet, String(dbErr.message || dbErr)],
      );
      return res.status(500).json({ error: "Clinic database provisioning failed." });
    }

    if (photo_base64 && photo_ext) {
      const ext = String(photo_ext).toLowerCase().replace(".", "");
      if (!ALLOWED_EXTENSIONS.has(ext)) {
        return res.status(400).json({ error: "Unsupported photo extension." });
      }

      await ensureCabinetPhotosDir();
      const buffer = Buffer.from(photo_base64, "base64");
      const fileName = `${cabinet.id_cabinet}.${ext}`;
      const filePath = path.join(CABINET_PHOTOS_DIR, fileName);
      await fs.writeFile(filePath, buffer);

      const updated = await pool.query(
        "UPDATE cabinet SET photo_url = $1 WHERE id_cabinet = $2 RETURNING *",
        [fileName, cabinet.id_cabinet],
      );
      cabinet = updated.rows[0];
    }

    // Clinic creator is automatically marked as clinic admin.
    await pool.query(
      `INSERT INTO cabinet_admin (id_cabinet, id_user, etat)
       VALUES ($1, $2, 1)
       ON CONFLICT (id_cabinet, id_user) DO UPDATE SET etat = 1`,
      [cabinet.id_cabinet, ownerId],
    );

    // Clinic creator is also auto-linked to this clinic as pending affiliation.
    await pool.query(
      `INSERT INTO users_cabinet (
         id_user,
         id_cabinet,
         type_access,
         status,
         requested_at,
         approved_at,
         approved_by
       )
       VALUES ($1, $2, 1, 0, NOW(), NULL, NULL)
       ON CONFLICT (id_cabinet, id_user)
       DO UPDATE SET
         type_access = 1,
         status = 0,
         requested_at = NOW(),
         approved_at = NULL,
         approved_by = NULL`,
      [ownerId, cabinet.id_cabinet],
    );

    return res.status(201).json(cabinet);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

export default router;
