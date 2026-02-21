import { Router } from "express";
import fs from "fs/promises";
import path from "path";

import { pool } from "../db.js";
import { ensureAffiliatedUser, ensureCabinetAdmin, ensurePlatformAdmin } from "../middleware/authorization.js";
import { provisionClinicDatabase } from "../services/clinic_db_service.js";
import { sendServerError } from "../utils/api_error.js";
import { logClinicAction } from "../utils/clinic_log.js";
import pg from "pg";

const router = Router();
const { Client } = pg;

const CABINET_PHOTOS_DIR = path.join(process.cwd(), "IMAGES", "CABINET");
const ALLOWED_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);

function clinicDbConfig(database) {
  return {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 5432),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database,
  };
}

async function getClinicDbName(cabinetId) {
  const result = await pool.query(
    `SELECT db_name
     FROM cabinet
     WHERE id_cabinet = $1
     LIMIT 1`,
    [cabinetId],
  );
  if (result.rowCount === 0) {
    const error = new Error("Clinic not found.");
    error.code = "CLINIC_NOT_FOUND";
    throw error;
  }
  const dbName = `${result.rows[0].db_name ?? ""}`.trim();
  if (!dbName) {
    const error = new Error("Clinic database not configured.");
    error.code = "3D000";
    throw error;
  }
  return dbName;
}

async function ensureConsultationParamsTable(client) {
  await client.query(`
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = current_schema()
          AND table_name = 'parametre_consulation'
      )
      AND NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = current_schema()
          AND table_name = 'parametre'
      ) THEN
        ALTER TABLE parametre_consulation RENAME TO parametre;
      END IF;
    END
    $$;
  `);
  await client.query(`
    CREATE TABLE IF NOT EXISTS parametre (
      singleton_id SMALLINT PRIMARY KEY DEFAULT 1 CHECK (singleton_id = 1),
      certificat_medical_enabled BOOLEAN NOT NULL DEFAULT TRUE,
      bilans_enabled BOOLEAN NOT NULL DEFAULT TRUE,
      lettre_orientation_enabled BOOLEAN NOT NULL DEFAULT TRUE,
      arret_travail_enabled BOOLEAN NOT NULL DEFAULT TRUE,
      rapports_medicaux_enabled BOOLEAN NOT NULL DEFAULT TRUE,
      gest_ordonnance TEXT NOT NULL DEFAULT 'selection_medicaments',
      updated_at TIMESTAMP NOT NULL DEFAULT NOW()
    )
  `);
  await client.query(`
    ALTER TABLE parametre
    ADD COLUMN IF NOT EXISTS gest_ordonnance TEXT NOT NULL DEFAULT 'selection_medicaments'
  `);
  await client.query(`
    INSERT INTO parametre (singleton_id)
    VALUES (1)
    ON CONFLICT (singleton_id) DO NOTHING
  `);
}

async function ensureCabinetPhotosDir() {
  await fs.mkdir(CABINET_PHOTOS_DIR, { recursive: true });
}

async function ensureUsersCabinetHistoryTable(client) {
  await client.query(
    `CREATE TABLE IF NOT EXISTS users_cabinet_history (
       id_history BIGSERIAL PRIMARY KEY,
       id_user BIGINT NOT NULL,
       id_cabinet BIGINT NOT NULL,
       snapshot JSONB NOT NULL,
       archived_reason TEXT NOT NULL,
       archived_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
     )`,
  );
}

async function resolveUsersCabinetSchema(client) {
  const columnsResult = await client.query(
    `SELECT column_name, data_type
     FROM information_schema.columns
     WHERE table_schema = current_schema()
       AND table_name = 'users_cabinet'`,
  );
  const columns = new Map(
    columnsResult.rows.map((row) => [String(row.column_name), String(row.data_type)]),
  );

  const hasStatus = columns.has("status");
  const hasEtat = columns.has("etat");
  const statusColumn = hasStatus ? "status" : (hasEtat ? "etat" : null);
  if (!statusColumn) {
    throw new Error("users_cabinet must contain status or etat column.");
  }

  const statusType = columns.get(statusColumn);
  const statusIsBoolean = statusType === "boolean";
  const hasRequestedAt = columns.has("requested_at");
  const hasApprovedAt = columns.has("approved_at");
  const hasApprovedBy = columns.has("approved_by");
  const hasDeniedAt = columns.has("denied_at");
  const hasDeniedBy = columns.has("denied_by");
  const canUseAuditColumns = hasRequestedAt && hasApprovedAt && hasApprovedBy && statusColumn === "status";
  const uniqueCheck = await client.query(
    `SELECT 1
     FROM pg_constraint c
     JOIN pg_class t ON t.oid = c.conrelid
     JOIN pg_namespace n ON n.oid = t.relnamespace
     WHERE n.nspname = current_schema()
       AND t.relname = 'users_cabinet'
       AND c.contype = 'u'
       AND (
         SELECT string_agg(a.attname, ',' ORDER BY ord)
         FROM unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord)
         JOIN pg_attribute a
           ON a.attrelid = c.conrelid
          AND a.attnum = k.attnum
       ) IN ('id_cabinet,id_user', 'id_user,id_cabinet')
     LIMIT 1`,
  );
  const hasUniquePair = uniqueCheck.rowCount > 0;
  return { statusColumn, statusIsBoolean, canUseAuditColumns, hasDeniedAt, hasDeniedBy, hasUniquePair };
}

async function ensureUsersCabinetAllowsHistory(client) {
  const constraints = await client.query(
    `SELECT c.conname
     FROM pg_constraint c
     JOIN pg_class t ON t.oid = c.conrelid
     JOIN pg_namespace n ON n.oid = t.relnamespace
     WHERE n.nspname = current_schema()
       AND t.relname = 'users_cabinet'
       AND c.contype = 'u'
       AND (
         SELECT string_agg(a.attname, ',' ORDER BY ord)
         FROM unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord)
         JOIN pg_attribute a
           ON a.attrelid = c.conrelid
          AND a.attnum = k.attnum
       ) IN ('id_cabinet,id_user', 'id_user,id_cabinet')`,
  );
  for (const row of constraints.rows) {
    await client.query(`ALTER TABLE users_cabinet DROP CONSTRAINT IF EXISTS "${row.conname}"`);
  }

  const indexes = await client.query(
    `SELECT idx.relname AS indexname
     FROM pg_index i
     JOIN pg_class tbl ON tbl.oid = i.indrelid
     JOIN pg_namespace n ON n.oid = tbl.relnamespace
     JOIN pg_class idx ON idx.oid = i.indexrelid
     WHERE n.nspname = current_schema()
       AND tbl.relname = 'users_cabinet'
       AND i.indisunique = true
       AND i.indisprimary = false
       AND (
         SELECT string_agg(a.attname, ',' ORDER BY ord)
         FROM unnest(i.indkey) WITH ORDINALITY AS k(attnum, ord)
         JOIN pg_attribute a
           ON a.attrelid = i.indrelid
          AND a.attnum = k.attnum
       ) IN ('id_cabinet,id_user', 'id_user,id_cabinet')`,
  );
  for (const row of indexes.rows) {
    try {
      await client.query(`DROP INDEX IF EXISTS "${row.indexname}"`);
    } catch (_) {
      // Ignore index drop failures (ownership/dependency); insertion path handles fallback.
    }
  }
}

async function upsertUsersCabinetPortable(client, { userId, cabinetId, typeAccess, status, approverId = null }) {
  const schema = await resolveUsersCabinetSchema(client);
  const statusColumn = schema.statusColumn;
  const statusIsBoolean = schema.statusIsBoolean;
  const statusValue = statusIsBoolean ? status === 1 : status;
  const approveNow = status === 1;

  const canUseAuditColumns = schema.canUseAuditColumns;

  if (canUseAuditColumns && schema.hasUniquePair) {
    await client.query(
      `INSERT INTO users_cabinet (id_user, id_cabinet, type_access, ${statusColumn}, requested_at, approved_at, approved_by)
       VALUES ($1, $2, $3, $4, NOW(), CASE WHEN $5 THEN NOW() ELSE NULL END, CASE WHEN $5 THEN $6::bigint ELSE NULL END)
       ON CONFLICT (id_cabinet, id_user)
       DO UPDATE SET
         type_access = EXCLUDED.type_access,
         ${statusColumn} = EXCLUDED.${statusColumn},
         requested_at = NOW(),
         approved_at = CASE WHEN $5 THEN NOW() ELSE users_cabinet.approved_at END,
         approved_by = CASE WHEN $5 THEN $6::bigint ELSE users_cabinet.approved_by END`,
      [userId, cabinetId, typeAccess, statusValue, approveNow, approverId],
    );
    return;
  }

  if (schema.hasUniquePair) {
    await client.query(
      `INSERT INTO users_cabinet (id_user, id_cabinet, type_access, ${statusColumn})
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (id_cabinet, id_user)
       DO UPDATE SET
         type_access = EXCLUDED.type_access,
         ${statusColumn} = EXCLUDED.${statusColumn}`,
      [userId, cabinetId, typeAccess, statusValue],
    );
    return;
  }

  // No unique pair: emulate upsert by updating active rows first, then inserting if none.
  const update = await client.query(
    `UPDATE users_cabinet
     SET type_access = $3, ${statusColumn} = $4
     WHERE id_user = $1 AND id_cabinet = $2 AND ${statusColumn} <> ${schema.statusIsBoolean ? "FALSE" : "2"}
     RETURNING 1`,
    [userId, cabinetId, typeAccess, statusValue],
  );
  if (update.rowCount > 0) {
    return;
  }
  await insertUsersCabinetPortable(client, { userId, cabinetId, typeAccess, status, approverId });
}

async function insertUsersCabinetPortable(client, { userId, cabinetId, typeAccess, status, approverId = null }) {
  const schema = await resolveUsersCabinetSchema(client);
  const statusColumn = schema.statusColumn;
  const statusIsBoolean = schema.statusIsBoolean;
  const statusValue = statusIsBoolean ? status === 1 : status;
  const approveNow = status === 1;

  if (schema.canUseAuditColumns) {
    await client.query(
      `INSERT INTO users_cabinet (id_user, id_cabinet, type_access, ${statusColumn}, requested_at, approved_at, approved_by)
       VALUES ($1, $2, $3, $4, NOW(), CASE WHEN $5 THEN NOW() ELSE NULL END, CASE WHEN $5 THEN $6::bigint ELSE NULL END)`,
      [userId, cabinetId, typeAccess, statusValue, approveNow, approverId],
    );
    return;
  }

  await client.query(
    `INSERT INTO users_cabinet (id_user, id_cabinet, type_access, ${statusColumn})
     VALUES ($1, $2, $3, $4)`,
    [userId, cabinetId, typeAccess, statusValue],
  );
}

function latestUsersCabinetOrderExpr(schema) {
  const terms = [];
  if (schema.canUseAuditColumns) {
    terms.push("requested_at");
    terms.push("approved_at");
  }
  if (schema.hasDeniedAt) {
    terms.push("denied_at");
  }
  if (terms.length === 0) {
    return "NOW()";
  }
  return `COALESCE(${terms.join(", ")}, NOW())`;
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
    return sendServerError(res, err);
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
    return sendServerError(res, err);
  }
});

router.get("/:id_cabinet/db-ready", async (req, res) => {
  try {
    const cabinetId = Number(req.params.id_cabinet);
    if (!Number.isInteger(cabinetId)) {
      return res.status(400).json({ error: "Invalid clinic id." });
    }

    const result = await pool.query(
      `SELECT db_name
       FROM cabinet
       WHERE id_cabinet = $1
       LIMIT 1`,
      [cabinetId],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Clinic not found." });
    }

    const dbName = `${result.rows[0].db_name ?? ""}`.trim();
    if (!dbName) {
      return res.status(503).json({ error: "Clinic database is not configured.", code: "DB_NOT_FOUND" });
    }

    const dbCheck = await pool.query(
      "SELECT 1 FROM pg_database WHERE datname = $1 LIMIT 1",
      [dbName],
    );
    if (dbCheck.rowCount === 0) {
      return res.status(503).json({ error: "Clinic database not found.", code: "DB_NOT_FOUND" });
    }

    return res.status(200).json({ ok: true, db_name: dbName });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.get("/open-days", async (req, res) => {
  try {
    const cabinetId = Number(req.query.id_cabinet);
    const userId = Number(req.query.id_user);
    if (!Number.isInteger(cabinetId) || !Number.isInteger(userId)) {
      return res.status(400).json({ error: "id_cabinet and id_user are required." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      const result = await client.query(
        `SELECT day_of_week, is_open
         FROM clinic_open_days
         ORDER BY day_of_week ASC`,
      );
      return res.status(200).json(result.rows);
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.get("/consultation-params", async (req, res) => {
  try {
    const cabinetId = Number(req.query.id_cabinet);
    const userId = Number(req.query.id_user);
    if (!Number.isInteger(cabinetId) || !Number.isInteger(userId)) {
      return res.status(400).json({ error: "id_cabinet and id_user are required." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      await ensureConsultationParamsTable(client);
      const result = await client.query(
        `SELECT
           certificat_medical_enabled,
           bilans_enabled,
           lettre_orientation_enabled,
           arret_travail_enabled,
           rapports_medicaux_enabled,
           gest_ordonnance
         FROM parametre
         WHERE singleton_id = 1
         LIMIT 1`,
      );
      return res.status(200).json(result.rows[0] ?? {});
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/consultation-params/update", async (req, res) => {
  try {
    const { id_cabinet, id_user, key, enabled, value } = req.body || {};
    const cabinetId = Number(id_cabinet);
    const userId = Number(id_user);
    const allowedBooleanColumns = new Set([
      "certificat_medical_enabled",
      "bilans_enabled",
      "lettre_orientation_enabled",
      "arret_travail_enabled",
      "rapports_medicaux_enabled",
    ]);
    const allowedTextColumns = new Set(["gest_ordonnance"]);
    const allowedGestOrdonnanceValues = new Set([
      "selection_medicaments",
      "saisie_prescription",
    ]);
    const column = `${key ?? ""}`.trim();
    const isBooleanColumn = allowedBooleanColumns.has(column);
    const isTextColumn = allowedTextColumns.has(column);
    if (!Number.isInteger(cabinetId) || !Number.isInteger(userId) || (!isBooleanColumn && !isTextColumn)) {
      return res.status(400).json({ error: "id_cabinet, id_user and key are required." });
    }
    const textValue = `${value ?? ""}`.trim();
    if (isTextColumn && !allowedGestOrdonnanceValues.has(textValue)) {
      return res.status(400).json({ error: "Invalid gest_ordonnance value." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      await ensureConsultationParamsTable(client);
      if (isBooleanColumn) {
        await client.query(
          `UPDATE parametre
           SET ${column} = $1,
               updated_at = NOW()
           WHERE singleton_id = 1`,
          [enabled === true],
        );
      } else {
        await client.query(
          `UPDATE parametre
           SET ${column} = $1::text,
               updated_at = NOW()
           WHERE singleton_id = 1`,
          [textValue],
        );
      }
      await logClinicAction({
        cabinetId,
        userId,
        actionType: "update",
        tableName: "parametre",
        rowId: "1",
        details: isBooleanColumn
          ? { key: column, enabled: enabled === true }
          : { key: column, value: textValue },
      });
      return res.status(200).json({ ok: true });
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/open-days/update", async (req, res) => {
  try {
    const { id_cabinet, id_user, day_of_week, is_open } = req.body || {};
    const cabinetId = Number(id_cabinet);
    const userId = Number(id_user);
    const day = Number(day_of_week);
    if (!Number.isInteger(cabinetId) || !Number.isInteger(userId) || !Number.isInteger(day)) {
      return res.status(400).json({ error: "id_cabinet, id_user and day_of_week are required." });
    }
    if (day < 1 || day > 7) {
      return res.status(400).json({ error: "day_of_week must be between 1 and 7." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      await client.query(
        `INSERT INTO clinic_open_days (day_of_week, is_open, updated_at)
         VALUES ($1, $2, NOW())
         ON CONFLICT (day_of_week)
         DO UPDATE SET
           is_open = EXCLUDED.is_open,
           updated_at = NOW()`,
        [day, is_open === true],
      );
      await logClinicAction({
        cabinetId,
        userId,
        actionType: "update",
        tableName: "clinic_open_days",
        rowId: day,
        details: { day_of_week: day, is_open: is_open === true },
      });
      return res.status(200).json({ ok: true });
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
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
    return sendServerError(res, err);
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
    return sendServerError(res, err);
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

    const schema = await resolveUsersCabinetSchema(pool);
    const orderExpr = latestUsersCabinetOrderExpr(schema);
    const existing = await pool.query(
      `SELECT *
       FROM users_cabinet
       WHERE id_user = $1 AND id_cabinet = $2
       ORDER BY ${orderExpr} DESC, ctid DESC
       LIMIT 1`,
      [userId, cabinetId],
    );
    if (existing.rowCount > 0) {
      const current = existing.rows[0];
      const rawStatus = current[schema.statusColumn];
      const currentStatus = schema.statusIsBoolean ? (rawStatus ? 1 : 0) : Number(rawStatus ?? 0);

      if (currentStatus === 0 || currentStatus === 1) {
        return res.status(409).json({ error: "Already assigned." });
      }

      if (currentStatus === 2) {
        await ensureUsersCabinetHistoryTable(pool);
        await pool.query(
          `INSERT INTO users_cabinet_history (id_user, id_cabinet, snapshot, archived_reason)
           VALUES ($1, $2, $3::jsonb, $4)`,
          [userId, cabinetId, JSON.stringify(current), "resubmitted_after_canceled"],
        );
        // If a unique (id_user,id_cabinet) constraint still exists, remove the canceled row
        // so a fresh pending request can be inserted.
        if (schema.hasUniquePair) {
          await pool.query(
            `DELETE FROM users_cabinet
             WHERE ctid IN (
               SELECT ctid
               FROM users_cabinet
               WHERE id_user = $1 AND id_cabinet = $2
               ORDER BY ${orderExpr} DESC, ctid DESC
               LIMIT 1
             )`,
            [userId, cabinetId],
          );
        }
      }
    }
    await ensureUsersCabinetAllowsHistory(pool);
    await insertUsersCabinetPortable(pool, {
      userId,
      cabinetId,
      typeAccess: type_access,
      status: 0,
      approverId: userId,
    });
    await logClinicAction({
      cabinetId,
      userId,
      actionType: "insert",
      tableName: "users_cabinet",
      rowId: `${userId}:${cabinetId}`,
      details: { status: 0, type_access },
    });

    return res.status(201).json({ ok: true, status: "pending" });
  } catch (err) {
    if (err && err.code === "23505") {
      return res.status(409).json({ error: "Already assigned." });
    }
    return sendServerError(res, err);
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

    const schema = await resolveUsersCabinetSchema(pool);
    const statusExpr = schema.statusIsBoolean ? "TRUE" : "1";
    const resetDeniedSql = schema.hasDeniedAt && schema.hasDeniedBy ? ", denied_at = NULL, denied_by = NULL" : "";
    const setApprovedSql = schema.canUseAuditColumns
      ? `approved_at = NOW(), approved_by = $3${resetDeniedSql},`
      : "";
    const orderExpr = latestUsersCabinetOrderExpr(schema);
    const result = await pool.query(
      `WITH target AS (
         SELECT ctid
         FROM users_cabinet
         WHERE id_user = $1 AND id_cabinet = $2
         ORDER BY ${orderExpr} DESC, ctid DESC
         LIMIT 1
       )
       UPDATE users_cabinet uc
       SET ${setApprovedSql} ${schema.statusColumn} = ${statusExpr}
       FROM target
       WHERE uc.ctid = target.ctid
       RETURNING uc.*`,
      [userId, cabinetId, adminId],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Request not found." });
    }
    await logClinicAction({
      cabinetId,
      userId: adminId,
      actionType: "update",
      tableName: "users_cabinet",
      rowId: `${userId}:${cabinetId}`,
      details: { status: 1, approved_by: adminId },
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
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

    const schema = await resolveUsersCabinetSchema(pool);
    const statusExpr = schema.statusIsBoolean ? "FALSE" : "2";
    const setDeniedSql = schema.hasDeniedAt && schema.hasDeniedBy ? "denied_at = NOW(), denied_by = $3," : "";
    const resetApprovedSql = schema.canUseAuditColumns ? "approved_at = NULL, approved_by = NULL," : "";
    const orderExpr = latestUsersCabinetOrderExpr(schema);
    const result = await pool.query(
      `WITH target AS (
         SELECT ctid
         FROM users_cabinet
         WHERE id_user = $1 AND id_cabinet = $2
         ORDER BY ${orderExpr} DESC, ctid DESC
         LIMIT 1
       )
       UPDATE users_cabinet uc
       SET ${setDeniedSql} ${resetApprovedSql} ${schema.statusColumn} = ${statusExpr}
       FROM target
       WHERE uc.ctid = target.ctid
       RETURNING uc.*`,
      [userId, cabinetId, adminId],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Request not found." });
    }
    await logClinicAction({
      cabinetId,
      userId: adminId,
      actionType: "cancel",
      tableName: "users_cabinet",
      rowId: `${userId}:${cabinetId}`,
      details: { status: 2, denied_by: adminId },
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.get("/users", async (req, res) => {
  try {
    const cabinetId = Number(req.query.id_cabinet);
    const requesterId = Number(req.query.id_user);
    if (!Number.isInteger(cabinetId) || !Number.isInteger(requesterId)) {
      return res.status(400).json({ error: "id_cabinet and id_user are required." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, requesterId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const rawState = String(req.query.state || "all").trim().toLowerCase();
    const state =
      rawState === "pending" ? 0 :
      rawState === "approved" ? 1 :
      null;
    const q = String(req.query.q || "").trim();
    const like = `%${q}%`;

    const adminCheck = await ensureCabinetAdmin(cabinetId, requesterId);
    const isCurrentUserAdmin = adminCheck.ok;

    const schema = await resolveUsersCabinetSchema(pool);
    const orderExpr = latestUsersCabinetOrderExpr(schema);
    const statusExpr = schema.statusIsBoolean
      ? `(CASE WHEN latest.${schema.statusColumn} THEN 1 ELSE 0 END)`
      : `latest.${schema.statusColumn}::int`;
    const result = await pool.query(
      `WITH latest AS (
         SELECT DISTINCT ON (uc.id_user)
           uc.*
         FROM users_cabinet uc
         WHERE uc.id_cabinet = $1
         ORDER BY uc.id_user, ${orderExpr} DESC, uc.ctid DESC
       )
       SELECT
         latest.id_user,
         latest.id_cabinet,
         latest.type_access,
         ${statusExpr} AS status,
         latest.requested_at,
         latest.approved_at,
         latest.denied_at,
         u.fullname,
         u.email,
         u.phone,
         u.role,
         CASE WHEN ca.id_user IS NULL THEN false ELSE true END AS is_admin
       FROM latest
       JOIN users u ON u.id_user = latest.id_user
       LEFT JOIN cabinet_admin ca
         ON ca.id_cabinet = latest.id_cabinet
        AND ca.id_user = latest.id_user
        AND ca.etat = 1
       WHERE ($2::int IS NULL OR ${statusExpr} = $2)
         AND (
           $3 = ''
           OR COALESCE(u.fullname, '') ILIKE $4
           OR COALESCE(u.email, '') ILIKE $4
           OR COALESCE(u.phone, '') ILIKE $4
         )
       ORDER BY
         (CASE WHEN ca.id_user IS NULL THEN 0 ELSE 1 END) DESC,
         ${statusExpr} ASC,
         COALESCE(NULLIF(TRIM(u.fullname), ''), NULLIF(TRIM(u.email), ''), CONCAT('ID ', u.id_user::text)) ASC`,
      [cabinetId, state, q, like],
    );

    return res.status(200).json({
      current_user_is_admin: isCurrentUserAdmin,
      items: result.rows,
    });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.get("/is-admin", async (req, res) => {
  try {
    const cabinetId = Number(req.query.id_cabinet);
    const userId = Number(req.query.id_user);
    if (!Number.isInteger(cabinetId) || !Number.isInteger(userId)) {
      return res.status(400).json({ error: "id_cabinet and id_user are required." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const adminCheck = await ensureCabinetAdmin(cabinetId, userId);
    return res.status(200).json({ is_admin: adminCheck.ok });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.get("/logs", async (req, res) => {
  try {
    const cabinetId = Number(req.query.id_cabinet);
    const userId = Number(req.query.id_user);
    if (!Number.isInteger(cabinetId) || !Number.isInteger(userId)) {
      return res.status(400).json({ error: "id_cabinet and id_user are required." });
    }

    const adminCheck = await ensureCabinetAdmin(cabinetId, userId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const mode = String(req.query.mode || "date").trim().toLowerCase();
    const date = String(req.query.date || "").trim();
    const from = String(req.query.from || "").trim();
    const to = String(req.query.to || "").trim();

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS log (
          id_log BIGSERIAL PRIMARY KEY,
          id_user BIGINT NULL,
          action_type TEXT NOT NULL CHECK (action_type IN ('insert', 'update', 'cancel', 'delete')),
          table_name TEXT NULL,
          row_id TEXT NULL,
          details JSONB NULL,
          created_at TIMESTAMP NOT NULL DEFAULT NOW()
        )
      `);

      let result;
      if (mode === "period") {
        result = await client.query(
          `SELECT id_log, id_user, action_type, table_name, row_id, details, created_at
           FROM log
           WHERE created_at::date >= COALESCE(NULLIF($1, '')::date, CURRENT_DATE)
             AND created_at::date <= COALESCE(NULLIF($2, '')::date, CURRENT_DATE)
           ORDER BY created_at DESC, id_log DESC`,
          [from, to],
        );
      } else {
        result = await client.query(
          `SELECT id_log, id_user, action_type, table_name, row_id, details, created_at
           FROM log
           WHERE created_at::date = COALESCE(NULLIF($1, '')::date, CURRENT_DATE)
           ORDER BY created_at DESC, id_log DESC`,
          [date],
        );
      }
      return res.status(200).json(result.rows);
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/admin/grant", async (req, res) => {
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
    if (adminId === userId) {
      return res.status(409).json({ error: "You cannot change your own admin role." });
    }

    const adminCheck = await ensureCabinetAdmin(cabinetId, adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const affiliationCheck = await pool.query(
      `SELECT 1
       FROM users_cabinet
       WHERE id_user = $1 AND id_cabinet = $2 AND status = 1
       LIMIT 1`,
      [userId, cabinetId],
    );
    if (affiliationCheck.rowCount === 0) {
      return res.status(409).json({ error: "User must be approved before becoming admin." });
    }

    await pool.query(
      `INSERT INTO cabinet_admin (id_cabinet, id_user, etat)
       VALUES ($1, $2, 1)
       ON CONFLICT (id_cabinet, id_user)
       DO UPDATE SET etat = 1`,
      [cabinetId, userId],
    );
    await logClinicAction({
      cabinetId,
      userId: adminId,
      actionType: "insert",
      tableName: "cabinet_admin",
      rowId: `${userId}:${cabinetId}`,
      details: { etat: 1 },
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/admin/revoke", async (req, res) => {
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
    if (adminId === userId) {
      return res.status(409).json({ error: "You cannot change your own admin role." });
    }

    const adminCheck = await ensureCabinetAdmin(cabinetId, adminId);
    if (!adminCheck.ok) {
      return res.status(adminCheck.status).json({ error: adminCheck.error });
    }

    const targetAdminCheck = await pool.query(
      `SELECT 1
       FROM cabinet_admin
       WHERE id_cabinet = $1 AND id_user = $2 AND etat = 1
       LIMIT 1`,
      [cabinetId, userId],
    );
    if (targetAdminCheck.rowCount === 0) {
      return res.status(404).json({ error: "Admin assignment not found." });
    }

    const adminsCount = await pool.query(
      `SELECT COUNT(*)::int AS total
       FROM cabinet_admin
       WHERE id_cabinet = $1 AND etat = 1`,
      [cabinetId],
    );
    const totalAdmins = adminsCount.rows[0]?.total ?? 0;
    if (totalAdmins <= 1) {
      return res.status(409).json({
        error: "Cannot remove admin role: this clinic needs at least one admin.",
        code: "LAST_ADMIN",
      });
    }

    await pool.query(
      `DELETE FROM cabinet_admin
       WHERE id_cabinet = $1 AND id_user = $2`,
      [cabinetId, userId],
    );
    await logClinicAction({
      cabinetId,
      userId: adminId,
      actionType: "delete",
      tableName: "cabinet_admin",
      rowId: `${userId}:${cabinetId}`,
      details: { etat: 0 },
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
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
    await logClinicAction({
      cabinetId,
      userId,
      actionType: "delete",
      tableName: "users_cabinet",
      rowId: `${userId}:${cabinetId}`,
      details: { detached: true },
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
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
      await upsertUsersCabinetPortable(client, {
        userId: adminUserId,
        cabinetId,
        typeAccess: 1,
        status: 1,
        approverId: adminId,
      });
    }

    await client.query("COMMIT");
    await logClinicAction({
      cabinetId,
      userId: adminId,
      actionType: "update",
      tableName: "cabinet",
      rowId: cabinetId,
      details: { etat: 1 },
    });
    return res.status(200).json({ ok: true });
  } catch (err) {
    try {
      await client.query("ROLLBACK");
    } catch (_) {}
    return sendServerError(res, err);
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
    await logClinicAction({
      cabinetId,
      userId: adminId,
      actionType: "cancel",
      tableName: "cabinet",
      rowId: cabinetId,
      details: { etat: 2 },
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
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
    await upsertUsersCabinetPortable(pool, {
      userId: ownerId,
      cabinetId: cabinet.id_cabinet,
      typeAccess: 1,
      status: 0,
      approverId: null,
    });
    await logClinicAction({
      cabinetId: cabinet.id_cabinet,
      userId: ownerId,
      actionType: "insert",
      tableName: "cabinet",
      rowId: cabinet.id_cabinet,
      details: { nom_cabinet: cabinet.nom_cabinet, etat: cabinet.etat },
    });

    return res.status(201).json(cabinet);
  } catch (err) {
    return sendServerError(res, err);
  }
});

export default router;
