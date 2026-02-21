import pg from "pg";

import { pool } from "../db.js";

const { Client } = pg;

function clinicDbConfig(database) {
  return {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 5432),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database,
  };
}

async function resolveClinicDbName(cabinetId) {
  const result = await pool.query(
    `SELECT db_name
     FROM cabinet
     WHERE id_cabinet = $1
     LIMIT 1`,
    [cabinetId],
  );
  if (result.rowCount === 0) return null;
  const dbName = `${result.rows[0].db_name ?? ""}`.trim();
  return dbName || null;
}

async function ensureLogTable(client) {
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
}

export async function logClinicAction({
  cabinetId,
  userId = null,
  actionType,
  tableName = null,
  rowId = null,
  details = null,
}) {
  try {
    if (!Number.isInteger(Number(cabinetId))) return;
    const dbName = await resolveClinicDbName(Number(cabinetId));
    if (!dbName) return;

    const client = new Client(clinicDbConfig(dbName));
    await client.connect();
    try {
      await ensureLogTable(client);
      await client.query(
        `INSERT INTO log (id_user, action_type, table_name, row_id, details)
         VALUES ($1, $2, $3, $4, $5::jsonb)`,
        [
          userId == null ? null : Number(userId),
          `${actionType}`,
          tableName == null ? null : `${tableName}`,
          rowId == null ? null : `${rowId}`,
          details == null ? null : JSON.stringify(details),
        ],
      );
    } finally {
      await client.end();
    }
  } catch (err) {
    // Logging failures must not break primary operations.
    console.error("Clinic log failed:", err?.message || err);
  }
}
