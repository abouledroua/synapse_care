UPDATE patients
SET sexe = (1 + floor(random() * 2))::int;
