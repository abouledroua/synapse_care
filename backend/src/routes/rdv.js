import { Router } from "express";
import pg from "pg";

import { pool } from "../db.js";
import { ensureCabinetStaff } from "../middleware/authorization.js";
import { sendServerError } from "../utils/api_error.js";
import { logClinicAction } from "../utils/clinic_log.js";

const router = Router();
const { Client } = pg;

function parseInteger(value) {
  const parsed = Number(value);
  return Number.isInteger(parsed) ? parsed : null;
}

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

router.get("/", async (req, res) => {
  try {
    const cabinetId = parseInteger(req.query.id_cabinet);
    const userId = parseInteger(req.query.id_user);
    if (cabinetId === null || userId === null) {
      return res.status(400).json({ error: "id_cabinet and id_user are required." });
    }

    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      const result = await client.query(
        `SELECT id_rdv, id_patient_global AS id_patient, date_rdv::text AS date_rdv, heure_rdv, heure_arrivee, num_rdv, motif_rdv, etat_rdv, created_at
         FROM rdv
         WHERE etat_rdv IN (0, 1)
         ORDER BY date_rdv DESC, heure_rdv DESC, id_rdv DESC`,
      );
      const rdvRows = result.rows;
      if (rdvRows.length === 0) {
        return res.json(rdvRows);
      }
      const patientIds = [...new Set(rdvRows.map((row) => Number(row.id_patient)).filter((v) => Number.isInteger(v)))];
      const patientMap = new Map();
      if (patientIds.length > 0) {
        const patientsResult = await pool.query(
          `SELECT id_patient, nom, prenom, age, type_age, photo_url
           FROM patient
           WHERE id_patient = ANY($1::int[])`,
          [patientIds],
        );
        for (const p of patientsResult.rows) {
          patientMap.set(Number(p.id_patient), p);
        }
      }
      const enriched = rdvRows.map((row) => {
        const p = patientMap.get(Number(row.id_patient));
        return {
          ...row,
          nom: p?.nom ?? "",
          prenom: p?.prenom ?? "",
          age: p?.age ?? null,
          type_age: p?.type_age ?? null,
          photo_url: p?.photo_url ?? "",
        };
      });
      return res.json(enriched);
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.get("/active", async (req, res) => {
  try {
    const cabinetId = parseInteger(req.query.id_cabinet);
    const userId = parseInteger(req.query.id_user);
    const patientId = parseInteger(req.query.id_patient);
    if (cabinetId === null || userId === null || patientId === null) {
      return res.status(400).json({ error: "id_cabinet, id_user and id_patient are required." });
    }

    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      const result = await client.query(
        `SELECT id_rdv, id_patient_global AS id_patient, date_rdv::text AS date_rdv, heure_rdv, heure_arrivee, num_rdv, motif_rdv, etat_rdv, created_at
         FROM rdv
         WHERE id_patient_global = $1 AND etat_rdv IN (0, 1)
         ORDER BY date_rdv DESC, heure_rdv DESC, id_rdv DESC
         LIMIT 1`,
        [patientId],
      );
      return res.json({ appointment: result.rowCount > 0 ? result.rows[0] : null });
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/", async (req, res) => {
  try {
      const {
        id_cabinet,
        id_user,
        id_patient,
        date_rdv,
        heure_rdv = null,
        motif_rdv = "",
      } = req.body || {};

    const cabinetId = parseInteger(id_cabinet);
    const userId = parseInteger(id_user);
    const patientId = parseInteger(id_patient);

    if (cabinetId === null || userId === null || patientId === null || !date_rdv) {
      return res.status(400).json({
        error: "id_cabinet, id_user, id_patient and date_rdv are required.",
      });
    }

    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const linked = await pool.query(
      `SELECT 1 FROM cabinet_patient WHERE id_cabinet = $1 AND id_patient = $2 LIMIT 1`,
      [cabinetId, patientId],
    );
    if (linked.rowCount === 0) {
      return res.status(404).json({ error: "Patient not found in this clinic." });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      const created = await client.query(
        `INSERT INTO rdv (
           id_patient_global, date_rdv, heure_rdv, heure_arrivee, num_rdv, motif_rdv, etat_rdv
         ) VALUES (
           $1,
           TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD'),
           $3,
           CASE
             WHEN TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD') = CURRENT_DATE THEN CURRENT_TIME
             ELSE NULL
           END,
           CASE
             WHEN TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD') = CURRENT_DATE THEN
               COALESCE((
                 SELECT MAX(num_rdv) + 1
                 FROM rdv
                 WHERE date_rdv = TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD')
                   AND etat_rdv = 1
               ), 1)
             ELSE 0
           END,
           $4,
           CASE
             WHEN TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD') = CURRENT_DATE THEN 1
             ELSE 0
           END
         )
         RETURNING id_rdv, id_patient_global AS id_patient, date_rdv::text AS date_rdv, heure_rdv, heure_arrivee, num_rdv, motif_rdv, etat_rdv, created_at`,
        [patientId, date_rdv, heure_rdv, motif_rdv],
      );
      await logClinicAction({
        cabinetId,
        userId,
        actionType: "insert",
        tableName: "rdv",
        rowId: created.rows[0]?.id_rdv,
        details: {
          id_patient: patientId,
          date_rdv,
          etat_rdv: created.rows[0]?.etat_rdv,
        },
      });
      return res.status(201).json(created.rows[0]);
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.put("/:id_rdv", async (req, res) => {
  try {
    const idRdv = parseInteger(req.params.id_rdv);
      const {
        id_cabinet,
        id_user,
        id_patient,
        date_rdv,
        heure_rdv = null,
        motif_rdv = "",
      } = req.body || {};

    const cabinetId = parseInteger(id_cabinet);
    const userId = parseInteger(id_user);
    const patientId = parseInteger(id_patient);

    if (
      idRdv === null ||
      cabinetId === null ||
      userId === null ||
      patientId === null ||
      !date_rdv
    ) {
      return res.status(400).json({
        error: "id_rdv, id_cabinet, id_user, id_patient and date_rdv are required.",
      });
    }

    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const dbName = await getClinicDbName(cabinetId);
    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      const updated = await client.query(
        `UPDATE rdv
         SET id_patient_global = $1,
             date_rdv = TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD'),
             heure_rdv = $3,
             heure_arrivee = CASE
               WHEN TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD') = CURRENT_DATE THEN CURRENT_TIME
               ELSE NULL
             END,
             num_rdv = CASE
               WHEN num_rdv <> 0
                    AND date_rdv = TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD')
                 THEN num_rdv
               WHEN TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD') = CURRENT_DATE THEN
                 COALESCE((
                   SELECT MAX(r2.num_rdv) + 1
                   FROM rdv r2
                   WHERE r2.date_rdv = TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD')
                     AND r2.etat_rdv = 1
                     AND r2.id_rdv <> $5
                 ), 1)
               ELSE 0
              END,
             motif_rdv = $4,
             etat_rdv = CASE
               WHEN TO_DATE(SUBSTRING($2::text, 1, 10), 'YYYY-MM-DD') = CURRENT_DATE THEN 1
               ELSE 0
              END
         WHERE id_rdv = $5
         RETURNING id_rdv, id_patient_global AS id_patient, date_rdv::text AS date_rdv, heure_rdv, heure_arrivee, num_rdv, motif_rdv, etat_rdv, created_at`,
        [patientId, date_rdv, heure_rdv, motif_rdv, idRdv],
      );
      if (updated.rowCount === 0) {
        return res.status(404).json({ error: "Appointment not found." });
      }
      await logClinicAction({
        cabinetId,
        userId,
        actionType: "update",
        tableName: "rdv",
        rowId: idRdv,
        details: {
          id_patient: patientId,
          date_rdv,
          etat_rdv: updated.rows[0]?.etat_rdv,
        },
      });
      return res.json(updated.rows[0]);
    } finally {
      await client.end();
    }
  } catch (err) {
    return sendServerError(res, err);
  }
});

export default router;
