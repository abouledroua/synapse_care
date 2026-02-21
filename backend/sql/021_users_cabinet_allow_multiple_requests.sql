BEGIN;

-- Add a surrogate primary key so (id_user, id_cabinet) can repeat across requests.
ALTER TABLE users_cabinet
  ADD COLUMN IF NOT EXISTS id_affiliation BIGSERIAL;

-- Drop PK/unique pair on (id_cabinet, id_user) if present.
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT c.conname
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = current_schema()
      AND t.relname = 'users_cabinet'
      AND c.contype IN ('p', 'u')
      AND (
        SELECT string_agg(a.attname, ',' ORDER BY ord)
        FROM unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord)
        JOIN pg_attribute a
          ON a.attrelid = c.conrelid
         AND a.attnum = k.attnum
      ) IN ('id_cabinet,id_user', 'id_user,id_cabinet')
  LOOP
    EXECUTE format('ALTER TABLE users_cabinet DROP CONSTRAINT IF EXISTS %I', r.conname);
  END LOOP;
END $$;

-- Make id_affiliation the primary key if no PK exists now.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = current_schema()
      AND t.relname = 'users_cabinet'
      AND c.contype = 'p'
  ) THEN
    ALTER TABLE users_cabinet
      ADD CONSTRAINT users_cabinet_pkey PRIMARY KEY (id_affiliation);
  END IF;
END $$;

-- Non-unique helper indexes for reads.
CREATE INDEX IF NOT EXISTS users_cabinet_user_cabinet_idx
  ON users_cabinet (id_user, id_cabinet);

CREATE INDEX IF NOT EXISTS users_cabinet_cabinet_status_idx
  ON users_cabinet (id_cabinet, status);

COMMIT;
