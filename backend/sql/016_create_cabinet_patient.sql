CREATE TABLE IF NOT EXISTS cabinet_patient (
  id_malade SERIAL PRIMARY KEY,
  id_cabinet INTEGER NOT NULL,
  id_patient INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT cabinet_patient_unique UNIQUE (id_cabinet, id_patient),
  CONSTRAINT cabinet_patient_cabinet_fk FOREIGN KEY (id_cabinet) REFERENCES cabinet (id_cabinet) ON DELETE CASCADE,
  CONSTRAINT cabinet_patient_patient_fk FOREIGN KEY (id_patient) REFERENCES patient (id_patient) ON DELETE CASCADE
);
