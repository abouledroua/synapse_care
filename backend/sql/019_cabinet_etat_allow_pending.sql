ALTER TABLE cabinet
  DROP CONSTRAINT IF EXISTS cabinet_etat_check;

ALTER TABLE cabinet
  ADD CONSTRAINT cabinet_etat_check CHECK (etat IN (0, 1, 2));
