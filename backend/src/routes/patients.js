import { Router } from "express";
import fs from "fs/promises";
import path from "path";

import { pool } from "../db.js";

const router = Router();

const PATIENT_PHOTOS_DIR = path.join(process.cwd(), "IMAGES", "PATIENT");
const ALLOWED_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);

async function ensurePatientPhotosDir() {
  await fs.mkdir(PATIENT_PHOTOS_DIR, { recursive: true });
}

router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM patient ORDER BY nom ASC, prenom ASC");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/", async (req, res) => {
  try {
    const {
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
      tel2,
      nin,
      nss,
      nb_impression,
      photo_base64,
      photo_ext,
    } = req.body || {};

    const missing = [];
    if (!nom) missing.push("nom");
    if (!prenom) missing.push("prenom");
    if (!date_naissance) missing.push("date_naissance");
    if (missing.length > 0) {
      return res
        .status(400)
        .json({ error: `Missing fields: ${missing.join(", ")}` });
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
    const safeTel2 = tel2 ? String(tel2).trim() : "";
    const safeNin = nin ? String(nin).trim() : "";
    const safeNss = nss ? String(nss).trim() : "";
    const safeNbImpression = 0;
    const safeAge = age ?? 0;

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
        tel2, nin, nss, nb_impression, code_malade, photo_url
      )
      VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9,
        $10, $11, $12, $13, $14, $15, $16, $17,
        $18, $19, $20, $21, $22, $23, $24
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
      tel2,
      nin,
      nss,
      nb_impression,
      photo_base64,
      photo_ext,
    } = req.body || {};

    const missing = [];
    if (!nom) missing.push("nom");
    if (!prenom) missing.push("prenom");
    if (!date_naissance) missing.push("date_naissance");
    if (missing.length > 0) {
      return res.status(400).json({ error: `Missing fields: ${missing.join(", ")}` });
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
    const safeTel2 = tel2 ? String(tel2).trim() : "";
    const safeNin = nin ? String(nin).trim() : "";
    const safeNss = nss ? String(nss).trim() : "";
    const safeNbImpression = 0;
    const safeAge = age ?? 0;

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
        tel2 = $19,
        nin = $20,
        nss = $21,
        nb_impression = $22
       WHERE id_patient = $23
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

router.get("/search", async (req, res) => {
  try {
    const q = String(req.query.q || "").trim();
    if (!q) return res.json([]);
    const like = `%${q}%`;
    const result = await pool.query(
      `SELECT *
       FROM patient
       WHERE nom ILIKE $1
          OR prenom ILIKE $1
          OR code_barre ILIKE $1
          OR tel1 ILIKE $1
          OR tel2 ILIKE $1
          OR email ILIKE $1
          OR nin ILIKE $1
          OR nss ILIKE $1
       ORDER BY nom ASC
       LIMIT 20`,
      [like],
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
