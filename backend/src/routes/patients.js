import { Router } from "express";
import fs from "fs/promises";
import path from "path";

import { pool } from "../db.js";
import { ensureAffiliatedUser, ensureCabinetStaff } from "../middleware/authorization.js";

const router = Router();

const PATIENT_PHOTOS_DIR = path.join(process.cwd(), "IMAGES", "PATIENT");
const ALLOWED_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);

async function ensurePatientPhotosDir() {
  await fs.mkdir(PATIENT_PHOTOS_DIR, { recursive: true });
}

function parseInteger(value) {
  const parsed = Number(value);
  return Number.isInteger(parsed) ? parsed : null;
}

async function ensurePatientLinkedToCabinet(cabinetId, patientId) {
  const result = await pool.query(
    `SELECT 1
     FROM cabinet_patient
     WHERE id_cabinet = $1 AND id_patient = $2
     LIMIT 1`,
    [cabinetId, patientId],
  );
  if (result.rowCount === 0) {
    return { ok: false, status: 404, error: "Patient not found in this clinic." };
  }
  return { ok: true };
}

router.get("/", async (req, res) => {
  try {
    const cabinetId = parseInteger(req.query.id_cabinet);
    const userId = parseInteger(req.query.id_user);
    if (cabinetId === null) {
      return res.status(400).json({ error: "id_cabinet is required." });
    }
    if (userId === null) {
      return res.status(400).json({ error: "id_user is required." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const result = await pool.query(
      `SELECT p.*
       FROM cabinet_patient cp
       JOIN patient p ON p.id_patient = cp.id_patient
       WHERE cp.id_cabinet = $1
       ORDER BY p.nom ASC, p.prenom ASC`,
      [cabinetId],
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/", async (req, res) => {
  try {
    const {
      id_user,
      id_cabinet,
      code_barre,
      nom,
      prenom,
      date_naissance,
      email,
      age,
      tel1,
      adresse,
      dette,
      presume,
      sexe,
      type_age,
      conventionne,
      pourc_conv,
      lieu_naissance,
      gs,
      profession,
      diagnostique,
      nationality,
      tel2,
      nin,
      nss,
      nb_impression,
      photo_base64,
      photo_ext,
    } = req.body || {};

    const missing = [];
    if (!id_user) missing.push("id_user");
    if (!id_cabinet) missing.push("id_cabinet");
    if (!nom) missing.push("nom");
    if (!prenom) missing.push("prenom");
    if (!date_naissance) missing.push("date_naissance");
    if (missing.length > 0) {
      return res
        .status(400)
        .json({ error: `Missing fields: ${missing.join(", ")}` });
    }

    const userId = parseInteger(id_user);
    const cabinetId = parseInteger(id_cabinet);
    if (userId === null) {
      return res.status(400).json({ error: "Invalid id_user." });
    }
    if (cabinetId === null) {
      return res.status(400).json({ error: "Invalid id_cabinet." });
    }

    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const safeCodeBarre = code_barre ? String(code_barre).trim() : "";
    const safeEmail = email ? String(email).trim() : "";
    const safeTel1 = tel1 ? String(tel1).trim() : "";
    const safeAdresse = adresse ? String(adresse).trim() : "";
    const safeDette = dette ?? 0;
    const safePresume = presume ?? 0;
    const safeSexe = sexe ?? 1;
    const safeTypeAge = type_age ?? 1;
    const safeConventionne = conventionne ?? 0;
    const safePourcConv = pourc_conv ?? 0;
    const safeLieuNaissance = lieu_naissance ? String(lieu_naissance).trim() : "";
    const safeGs = gs ?? 1;
    const safeProfession = profession ? String(profession).trim() : "";
    const safeDiagnostique = diagnostique ? String(diagnostique).trim() : "";
    const safeNationality = Number.isInteger(Number(nationality))
      ? Number(nationality)
      : null;
    const safeTel2 = tel2 ? String(tel2).trim() : "";
    const safeNin = nin ? String(nin).trim() : "";
    const safeNss = nss ? String(nss).trim() : "";
    const safeNbImpression = nb_impression ?? 0;
    const safeAge = age ?? 0;

    const existingConditions = [];
    const params = [];
    params.push(nom.toLowerCase(), prenom.toLowerCase(), date_naissance);
    existingConditions.push(
      "(LOWER(nom) = $1 AND LOWER(prenom) = $2 AND date_naissance = $3)",
    );
    if (safeNin) {
      params.push(safeNin);
      existingConditions.push(`(nin = $${params.length})`);
    }
    if (safeNss) {
      params.push(safeNss);
      existingConditions.push(`(nss = $${params.length})`);
    }

    const existingResult = await pool.query(
      `SELECT * FROM patient WHERE ${existingConditions.join(" OR ")} LIMIT 1`,
      params,
    );
    if (existingResult.rowCount > 0) {
      const patient = existingResult.rows[0];
      return res.status(409).json({
        error: "Patient already exists.",
        can_link: true,
        patient,
      });
    }

    if (safeTel1 || safeTel2) {
      const phoneCheck = await pool.query(
        `SELECT id_patient, tel1, tel2
         FROM patient
         WHERE ($1 <> '' AND (tel1 = $1 OR tel2 = $1))
            OR ($2 <> '' AND (tel1 = $2 OR tel2 = $2))
         LIMIT 1`,
        [safeTel1, safeTel2],
      );
      if (phoneCheck.rowCount > 0) {
        return res.status(409).json({ error: "Phone number already exists." });
      }
    }

    if (safeNationality !== null && (safeNin || safeNss)) {
      const ninNssParams = [safeNationality];
      const ninNssChecks = [];
      if (safeNin) {
        ninNssParams.push(safeNin);
        ninNssChecks.push(`(nationality = $1 AND nin = $${ninNssParams.length})`);
      }
      if (safeNss) {
        ninNssParams.push(safeNss);
        ninNssChecks.push(`(nationality = $1 AND nss = $${ninNssParams.length})`);
      }
      const ninNssCheck = await pool.query(
        `SELECT * FROM patient WHERE ${ninNssChecks.join(" OR ")} LIMIT 1`,
        ninNssParams,
      );
      if (ninNssCheck.rowCount > 0) {
        return res.status(409).json({
          error: "NIN or NSS already exists for this nationality.",
          can_link: true,
          patient: ninNssCheck.rows[0],
        });
      }
    }

    const prefix =
      `${String(nom).trim()[0] ?? ""}${String(prenom).trim()[0] ?? ""}`.toUpperCase();
    const like = `${prefix}%`;
    const lastCode = await pool.query(
      "SELECT code_malade FROM patient WHERE code_malade LIKE $1 ORDER BY code_malade DESC LIMIT 1",
      [like],
    );
    let nextNumber = 1;
    if (lastCode.rowCount > 0) {
      const last = String(lastCode.rows[0].code_malade || "");
      const match = last.match(/(\d+)$/);
      if (match) {
        nextNumber = Number.parseInt(match[1], 10) + 1;
      }
    }
    const code_malade = `${prefix}${String(nextNumber).padStart(4, "0")}`;

    const result = await pool.query(
      `INSERT INTO patient (
        code_barre, nom, prenom, date_naissance, email, age, tel1, adresse, dette,
        presume, sexe, type_age, conventionne, pourc_conv, lieu_naissance, gs, profession, diagnostique,
        nationality, tel2, nin, nss, nb_impression, code_malade, photo_url
      )
      VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9,
        $10, $11, $12, $13, $14, $15, $16, $17,
        $18, $19, $20, $21, $22, $23, $24, $25
      )
      RETURNING *`,
      [
        safeCodeBarre,
        nom,
        prenom,
        date_naissance,
        safeEmail,
        safeAge,
        safeTel1,
        safeAdresse,
        safeDette,
        safePresume,
        safeSexe,
        safeTypeAge,
        safeConventionne,
        safePourcConv,
        safeLieuNaissance,
        safeGs,
        safeProfession,
        safeDiagnostique,
        safeNationality,
        safeTel2,
        safeNin,
        safeNss,
        safeNbImpression,
        code_malade,
        "",
      ],
    );

    let patient = result.rows[0];

    if (photo_base64 && photo_ext) {
      const ext = String(photo_ext).toLowerCase().replace(".", "");
      if (!ALLOWED_EXTENSIONS.has(ext)) {
        return res.status(400).json({ error: "Unsupported photo extension." });
      }

      await ensurePatientPhotosDir();
      const buffer = Buffer.from(photo_base64, "base64");
      const fileName = `${patient.id_patient}.${ext}`;
      const filePath = path.join(PATIENT_PHOTOS_DIR, fileName);
      await fs.writeFile(filePath, buffer);

      const updated = await pool.query(
        "UPDATE patient SET photo_url = $1 WHERE id_patient = $2 RETURNING *",
        [fileName, patient.id_patient],
      );
      patient = updated.rows[0];
    }

    await pool.query(
      `INSERT INTO cabinet_patient (id_cabinet, id_patient)
       VALUES ($1, $2)
       ON CONFLICT (id_cabinet, id_patient) DO NOTHING`,
      [cabinetId, patient.id_patient],
    );

    return res.status(201).json(patient);
  } catch (err) {
    if (err && err.code === "23505") {
      return res.status(409).json({ error: "Patient already exists." });
    }
    return res.status(500).json({ error: err.message });
  }
});

router.put("/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) {
      return res.status(400).json({ error: "Invalid patient id." });
    }

    const {
      id_user,
      id_cabinet,
      code_barre,
      nom,
      prenom,
      date_naissance,
      email,
      age,
      tel1,
      adresse,
      dette,
      presume,
      sexe,
      type_age,
      conventionne,
      pourc_conv,
      lieu_naissance,
      gs,
      profession,
      diagnostique,
      nationality,
      tel2,
      nin,
      nss,
      nb_impression,
      photo_base64,
      photo_ext,
    } = req.body || {};

    const missing = [];
    if (!id_user) missing.push("id_user");
    if (!id_cabinet) missing.push("id_cabinet");
    if (!nom) missing.push("nom");
    if (!prenom) missing.push("prenom");
    if (!date_naissance) missing.push("date_naissance");
    if (missing.length > 0) {
      return res.status(400).json({ error: `Missing fields: ${missing.join(", ")}` });
    }

    const userId = parseInteger(id_user);
    const cabinetId = parseInteger(id_cabinet);
    if (userId === null) {
      return res.status(400).json({ error: "Invalid id_user." });
    }
    if (cabinetId === null) {
      return res.status(400).json({ error: "Invalid id_cabinet." });
    }

    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const linkCheck = await ensurePatientLinkedToCabinet(cabinetId, id);
    if (!linkCheck.ok) {
      return res.status(linkCheck.status).json({ error: linkCheck.error });
    }

    const safeCodeBarre = code_barre ? String(code_barre).trim() : "";
    const safeEmail = email ? String(email).trim() : "";
    const safeTel1 = tel1 ? String(tel1).trim() : "";
    const safeAdresse = adresse ? String(adresse).trim() : "";
    const safeDette = 0;
    const safePresume = presume ?? 0;
    const safeSexe = sexe ?? 1;
    const safeTypeAge = type_age ?? 1;
    const safeConventionne = conventionne ?? 0;
    const safePourcConv = pourc_conv ?? 0;
    const safeLieuNaissance = lieu_naissance ? String(lieu_naissance).trim() : "";
    const safeGs = gs ?? 1;
    const safeProfession = profession ? String(profession).trim() : "";
    const safeDiagnostique = diagnostique ? String(diagnostique).trim() : "";
    const safeNationality = Number.isInteger(Number(nationality))
      ? Number(nationality)
      : null;
    const safeTel2 = tel2 ? String(tel2).trim() : "";
    const safeNin = nin ? String(nin).trim() : "";
    const safeNss = nss ? String(nss).trim() : "";
    const safeNbImpression = 0;
    const safeAge = age ?? 0;

    if (safeTel1 || safeTel2) {
      const phoneCheck = await pool.query(
        `SELECT id_patient, tel1, tel2
         FROM patient
         WHERE id_patient <> $3
           AND (
             ($1 <> '' AND (tel1 = $1 OR tel2 = $1))
             OR ($2 <> '' AND (tel1 = $2 OR tel2 = $2))
           )
         LIMIT 1`,
        [safeTel1, safeTel2, id],
      );
      if (phoneCheck.rowCount > 0) {
        return res.status(409).json({ error: "Phone number already exists." });
      }
    }

    const result = await pool.query(
      `UPDATE patient SET
        code_barre = $1,
        nom = $2,
        prenom = $3,
        date_naissance = $4,
        email = $5,
        age = $6,
        tel1 = $7,
        adresse = $8,
        dette = $9,
        presume = $10,
        sexe = $11,
        type_age = $12,
        conventionne = $13,
        pourc_conv = $14,
        lieu_naissance = $15,
        gs = $16,
        profession = $17,
        diagnostique = $18,
        nationality = $19,
        tel2 = $20,
        nin = $21,
        nss = $22,
        nb_impression = $23
       WHERE id_patient = $24
       RETURNING *`,
      [
        safeCodeBarre,
        nom,
        prenom,
        date_naissance,
        safeEmail,
        safeAge,
        safeTel1,
        safeAdresse,
        safeDette,
        safePresume,
        safeSexe,
        safeTypeAge,
        safeConventionne,
        safePourcConv,
        safeLieuNaissance,
        safeGs,
        safeProfession,
        safeDiagnostique,
        safeNationality,
        safeTel2,
        safeNin,
        safeNss,
        safeNbImpression,
        id,
      ],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Patient not found." });
    }

    let patient = result.rows[0];

    if (photo_base64 && photo_ext) {
      const ext = String(photo_ext).toLowerCase().replace(".", "");
      if (!ALLOWED_EXTENSIONS.has(ext)) {
        return res.status(400).json({ error: "Unsupported photo extension." });
      }

      await ensurePatientPhotosDir();
      const buffer = Buffer.from(photo_base64, "base64");
      const fileName = `${patient.id_patient}.${ext}`;
      const filePath = path.join(PATIENT_PHOTOS_DIR, fileName);
      await fs.writeFile(filePath, buffer);

      const updated = await pool.query(
        "UPDATE patient SET photo_url = $1 WHERE id_patient = $2 RETURNING *",
        [fileName, patient.id_patient],
      );
      patient = updated.rows[0];
    }

    return res.status(200).json(patient);
  } catch (err) {
    if (err && err.code === "23505") {
      return res.status(409).json({ error: "Patient already exists." });
    }
    return res.status(500).json({ error: err.message });
  }
});

router.post("/link", async (req, res) => {
  try {
    const { id_user, id_cabinet, id_patient } = req.body || {};
    const userId = parseInteger(id_user);
    const cabinetId = parseInteger(id_cabinet);
    const patientId = parseInteger(id_patient);
    if (userId === null || cabinetId === null || patientId === null) {
      return res.status(400).json({ error: "Invalid ids." });
    }
    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }
    await pool.query(
      `INSERT INTO cabinet_patient (id_cabinet, id_patient)
       VALUES ($1, $2)
       ON CONFLICT (id_cabinet, id_patient) DO NOTHING`,
      [cabinetId, patientId],
    );
    return res.status(201).json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    const id = parseInteger(req.params.id);
    const userId = parseInteger(req.query.id_user);
    const cabinetId = parseInteger(req.query.id_cabinet);
    if (id === null) {
      return res.status(400).json({ error: "Invalid patient id." });
    }
    if (userId === null || cabinetId === null) {
      return res.status(400).json({ error: "id_user and id_cabinet are required." });
    }

    const accessCheck = await ensureCabinetStaff(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    const linkCheck = await ensurePatientLinkedToCabinet(cabinetId, id);
    if (!linkCheck.ok) {
      return res.status(linkCheck.status).json({ error: linkCheck.error });
    }

    const result = await pool.query("DELETE FROM patient WHERE id_patient = $1", [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Patient not found." });
    }
    return res.status(200).json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

router.get("/search", async (req, res) => {
  try {
    const q = String(req.query.q || "").trim();
    const cabinetId = parseInteger(req.query.id_cabinet);
    const userId = parseInteger(req.query.id_user);
    if (cabinetId === null) {
      return res.status(400).json({ error: "id_cabinet is required." });
    }
    if (userId === null) {
      return res.status(400).json({ error: "id_user is required." });
    }

    const accessCheck = await ensureAffiliatedUser(cabinetId, userId);
    if (!accessCheck.ok) {
      return res.status(accessCheck.status).json({ error: accessCheck.error });
    }

    if (!q) return res.json([]);
    const like = `%${q}%`;
    const result = await pool.query(
      `SELECT *
       FROM patient p
       JOIN cabinet_patient cp ON cp.id_patient = p.id_patient
       WHERE cp.id_cabinet = $2
         AND (
           p.nom ILIKE $1
           OR p.prenom ILIKE $1
           OR p.code_barre ILIKE $1
           OR p.tel1 ILIKE $1
           OR p.tel2 ILIKE $1
           OR p.email ILIKE $1
           OR p.nin ILIKE $1
           OR p.nss ILIKE $1
         )
       ORDER BY nom ASC
       LIMIT 20`,
      [like, cabinetId],
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
