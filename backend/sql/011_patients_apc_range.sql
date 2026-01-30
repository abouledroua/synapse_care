UPDATE patients
SET apc = (1 + floor(random() * 8))::int;
