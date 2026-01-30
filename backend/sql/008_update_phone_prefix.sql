UPDATE patients
SET
  tel1 = CASE
    WHEN tel1 LIKE '+213%' THEN tel1
    WHEN tel1 IS NULL OR tel1 = '' THEN tel1
    WHEN left(tel1, 1) = '0' THEN '+213' || substring(tel1 from 2)
    ELSE tel1
  END,
  tel2 = CASE
    WHEN tel2 LIKE '+213%' THEN tel2
    WHEN tel2 IS NULL OR tel2 = '' THEN tel2
    WHEN left(tel2, 1) = '0' THEN '+213' || substring(tel2 from 2)
    ELSE tel2
  END
WHERE email LIKE 'patient%@example.com';
