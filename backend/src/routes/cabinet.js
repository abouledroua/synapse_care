import { Router } from "express";
import fs from "fs/promises";
import path from "path";

import { pool } from "../db.js";

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
      `SELECT c.*
       FROM users_cabinet uc
       LEFT JOIN cabinet c ON c.id_cabinet = uc.id_cabinet
       WHERE uc.id_user = $1
       ORDER BY c.nom_cabinet ASC`,
      [id],
    );

    return res.json(result.rows);
  } catch (err) {
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
         ORDER BY nom_cabinet ASC
         LIMIT 5`,
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

router.post("/assign", async (req, res) => {
  try {
    const { id_user, id_cabinet, type_access = 1, etat = 1 } = req.body || {};
    const userId = Number(id_user);
    const cabinetId = Number(id_cabinet);
    if (!Number.isInteger(userId) || !Number.isInteger(cabinetId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    await pool.query(
      `INSERT INTO users_cabinet (id_user, id_cabinet, type_access, etat)
       VALUES ($1, $2, $3, $4)`,
      [userId, cabinetId, type_access, etat],
    );

    return res.status(201).json({ ok: true });
  } catch (err) {
    if (err && err.code === "23505") {
      return res.status(409).json({ error: "Already assigned." });
    }
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

    const result = await pool.query(
      "DELETE FROM users_cabinet WHERE id_user = $1 AND id_cabinet = $2",
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

router.post("/", async (req, res) => {
  try {
    const {
      nom_cabinet,
      adresse_cabinet,
      specialite_cabinet,
      phone,
      photo_base64,
      photo_ext,
    } = req.body || {};

    const missing = [];
    if (!nom_cabinet) missing.push("nom_cabinet");
    if (!phone) missing.push("phone");

    if (missing.length > 0) {
      return res
        .status(400)
        .json({ error: `Missing fields: ${missing.join(", ")}` });
    }

    const nameCheck = await pool.query(
      "SELECT 1 FROM cabinet WHERE LOWER(nom_cabinet) = LOWER($1) LIMIT 1",
      [nom_cabinet.trim()],
    );
    if (nameCheck.rowCount > 0) {
      return res.status(409).json({ error: "Cabinet name already exists." });
    }

    const created = await pool.query(
      `INSERT INTO cabinet (nom_cabinet, adresse_cabinet, specialite_cabinet, phone, photo_url, etat)
       VALUES ($1, $2, $3, $4, $5, 1)
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
        "",
      ],
    );

    let cabinet = created.rows[0];

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

    return res.status(201).json(cabinet);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

export default router;
