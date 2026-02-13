ALTER TABLE cabinet
  ADD COLUMN IF NOT EXISTS db_name TEXT,
  ADD COLUMN IF NOT EXISTS db_status SMALLINT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS db_created_at TIMESTAMP NULL,
  ADD COLUMN IF NOT EXISTS db_last_error TEXT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'cabinet'::regclass
      AND conname = 'cabinet_db_status_check'
  ) THEN
    ALTER TABLE cabinet
      ADD CONSTRAINT cabinet_db_status_check CHECK (db_status IN (0, 1, 2));
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS cabinet_db_name_unique_idx
  ON cabinet (db_name)
  WHERE db_name IS NOT NULL;
