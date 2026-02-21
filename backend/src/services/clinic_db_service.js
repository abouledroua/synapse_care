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
        heure_rdv TIME NULL,
        heure_arrivee TIME NULL,
        num_rdv INTEGER NOT NULL,
        motif_rdv TEXT NULL,
        etat_rdv SMALLINT NOT NULL DEFAULT 0,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Make appointment time optional for existing clinic databases.
    await client.query(`
      ALTER TABLE rdv
      ALTER COLUMN heure_rdv DROP NOT NULL
    `);
    await client.query(`
      ALTER TABLE rdv
      ALTER COLUMN heure_arrivee DROP NOT NULL
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

    await client.query(`
      CREATE TABLE IF NOT EXISTS clinic_open_days (
        day_of_week SMALLINT PRIMARY KEY,
        is_open BOOLEAN NOT NULL DEFAULT TRUE,
        updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
        CHECK (day_of_week BETWEEN 1 AND 7)
      )
    `);

    // Seed default open days (1..7) for new and existing clinic databases.
    await client.query(`
      INSERT INTO clinic_open_days (day_of_week, is_open)
      SELECT gs, TRUE
      FROM generate_series(1, 7) AS gs
      ON CONFLICT (day_of_week) DO NOTHING
    `);

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

    await client.query(
      "CREATE INDEX IF NOT EXISTS rdv_patient_idx ON rdv (id_patient_global)",
    );
    await client.query(
      "CREATE INDEX IF NOT EXISTS rdv_date_idx ON rdv (date_rdv)",
    );
    await client.query(
      "CREATE INDEX IF NOT EXISTS consultation_patient_idx ON consultation (id_patient_global)",
    );
    await client.query(
      "CREATE INDEX IF NOT EXISTS log_created_at_idx ON log (created_at DESC)",
    );
    await client.query(
      "CREATE INDEX IF NOT EXISTS log_action_type_idx ON log (action_type)",
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

export async function ensureAllClinicDatabasesSchema(globalPool) {
  const result = await globalPool.query(
    `SELECT db_name
     FROM cabinet
     WHERE COALESCE(TRIM(db_name), '') <> ''`,
  );
  for (const row of result.rows) {
    const dbName = `${row.db_name ?? ""}`.trim();
    if (!dbName) continue;
    await ensureDatabaseExists(dbName);
    await applyClinicSchema(dbName);
  }
}
