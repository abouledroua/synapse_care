BEGIN;

ALTER TABLE users_cabinet DROP CONSTRAINT IF EXISTS users_cabinet_pkey;

ALTER TABLE users_cabinet
  ADD CONSTRAINT users_cabinet_pkey PRIMARY KEY (id_affiliation);

ALTER TABLE users_cabinet
  DROP COLUMN IF EXISTS num;

COMMIT;
