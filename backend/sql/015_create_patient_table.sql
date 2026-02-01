DROP TABLE IF EXISTS patient;

CREATE TABLE patient (
  id_patient SERIAL PRIMARY KEY,
  LIKE patients INCLUDING DEFAULTS INCLUDING CONSTRAINTS
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'patient'::regclass
      AND conname = 'patient_code_barre_key'
  ) THEN
    ALTER TABLE patient ADD CONSTRAINT patient_code_barre_key UNIQUE (code_barre);
  END IF;
END $$;
