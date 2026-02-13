import pg from "pg";

const { Client } = pg;

function quoteIdentifier(identifier) {
  return `"${String(identifier).replace(/"/g, '""')}"`;
}

function buildClinicDatabaseName(cabinetId) {
  return `clinic_${cabinetId}`;
}

function adminConfig(database) {
  return {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 5432),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database,
  };
}

async function ensureDatabaseExists(dbName) {
  const adminDb = process.env.DB_ADMIN_DATABASE || "postgres";
  const client = new Client(adminConfig(adminDb));
  await client.connect();
  try {
    const exists = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = $1 LIMIT 1",
      [dbName],
    );
    if (exists.rowCount === 0) {
      await client.query(`CREATE DATABASE ${quoteIdentifier(dbName)}`);
    }
  } finally {
    await client.end();
  }
}

async function applyClinicSchema(dbName) {
  const client = new Client(adminConfig(dbName));
  await client.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS clinic_patient (
        id_patient_global INTEGER PRIMARY KEY,
        first_seen_at TIMESTAMP NOT NULL DEFAULT NOW(),
        last_seen_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS rdv (
        id_rdv SERIAL PRIMARY KEY,
        id_patient_global INTEGER NOT NULL,
        date_rdv DATE NOT NULL,
        heure_rdv TIME NOT NULL,
        heure_arrivee TIME NULL,
        num_rdv INTEGER NOT NULL,
        motif_rdv TEXT NULL,
        etat_rdv SMALLINT NOT NULL DEFAULT 0,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS consultation (
        id_consultation SERIAL PRIMARY KEY,
        id_patient_global INTEGER NOT NULL,
        consultation_date TIMESTAMP NOT NULL DEFAULT NOW(),
        motif TEXT NULL,
        note TEXT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    await client.query(
      "CREATE INDEX IF NOT EXISTS rdv_patient_idx ON rdv (id_patient_global)",
    );
    await client.query(
      "CREATE INDEX IF NOT EXISTS consultation_patient_idx ON consultation (id_patient_global)",
    );
  } finally {
    await client.end();
  }
}

export async function provisionClinicDatabase(cabinetId) {
  const dbName = buildClinicDatabaseName(cabinetId);
  await ensureDatabaseExists(dbName);
  await applyClinicSchema(dbName);
  return dbName;
}
