import express from "express";
import dotenv from "dotenv";
import { pool } from "./db.js";
import bcrypt from "bcryptjs";
import cors from "cors";
import fs from "fs/promises";
import path from "path";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use(
  "/photos",
  express.static(path.join(process.cwd(), "IMAGES", "Photos")),
);
app.use(
  "/IMAGES/Cabinets",
  express.static(path.join(process.cwd(), "IMAGES", "Cabinets")),
);

const PHOTOS_DIR = path.join(process.cwd(), "IMAGES", "Photos");
const ALLOWED_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);

async function ensurePhotosDir() {
  await fs.mkdir(PHOTOS_DIR, { recursive: true });
}

app.get("/health", async (req, res) => {
  try {
    const result = await pool.query("SELECT 1 AS ok");
    res.json({ ok: true, db: result.rows[0].ok });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});

app.post("/auth/signup", async (req, res) => {
  try {
    const {
      fullname,
      email,
      phone,
      password,
      speciality,
      photo_url,
      photo_base64,
      photo_ext,
    } = req.body || {};

    const missing = [];
    if (!fullname) missing.push("fullname");
    if (!email) missing.push("email");
    if (!password) missing.push("password");
    if (!speciality) missing.push("speciality");

    if (missing.length > 0) {
      return res
        .status(400)
        .json({ error: `Missing fields: ${missing.join(", ")}` });
    }

    if (phone) {
      const phoneCheck = await pool.query(
        "SELECT 1 FROM users WHERE phone = $1 LIMIT 1",
        [phone],
      );
      if (phoneCheck.rowCount > 0) {
        return res.status(409).json({ error: "Phone number already exists." });
      }
    }

    const emailCheck = await pool.query(
      "SELECT 1 FROM users WHERE email = $1 LIMIT 1",
      [email],
    );
    if (emailCheck.rowCount > 0) {
      return res.status(409).json({ error: "Email already exists." });
    }

    const rounds = Number(process.env.BCRYPT_ROUNDS || 10);
    const passwordHash = await bcrypt.hash(password, rounds);

    const result = await pool.query(
      `INSERT INTO users (fullname, email, phone, password, type, speciality, photo_url)
       VALUES ($1, $2, $3, $4, 1, $5, $6)
       RETURNING id_user, fullname, email, phone, type, speciality, photo_url`,
      [
        fullname,
        email,
        phone || null,
        passwordHash,
        speciality,
        photo_url || null,
      ],
    );

    const user = result.rows[0];

    if (photo_base64 && photo_ext) {
      const ext = String(photo_ext).toLowerCase().replace(".", "");
      if (!ALLOWED_EXTENSIONS.has(ext)) {
        return res.status(400).json({ error: "Unsupported photo extension." });
      }

      await ensurePhotosDir();
      const buffer = Buffer.from(photo_base64, "base64");
      const fileName = `${user.id_user}.${ext}`;
      const filePath = path.join(PHOTOS_DIR, fileName);
      await fs.writeFile(filePath, buffer);

      const photoUrl = fileName;
      const updated = await pool.query(
        "UPDATE users SET photo_url = $1 WHERE id_user = $2 RETURNING id_user, fullname, email, phone, type, speciality, photo_url",
        [photoUrl, user.id_user],
      );
      return res.status(201).json(updated.rows[0]);
    }

    return res.status(201).json(user);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body || {};

    if (!email || !password) {
      return res
        .status(400)
        .json({ error: "Email and password are required." });
    }

    const result = await pool.query(
      "SELECT id_user, fullname, email, phone, password, type, speciality, photo_url FROM users WHERE email = $1 AND type = 1 LIMIT 1",
      [email],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Doctor not found." });
    }

    const user = result.rows[0];
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({ error: "Invalid password." });
    }

    delete user.password;
    return res.status(200).json(user);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.get("/cabinet/by-user/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) {
      return res.status(400).json({ error: "Invalid user id." });
    }

    const result = await pool.query(
      `SELECT c.*
       FROM users_cabinet uc
       LEFT JOIN cabinet c ON c.id_cabinet = uc.id_cabinet
       WHERE uc.id_user = $1
       ORDER BY c.id_cabinet ASC`,
      [id],
    );

    return res.json(result.rows);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.get("/cabinet/search", async (req, res) => {
  try {
    const q = String(req.query.q || "").trim();
    let result;
    if (!q) {
      result = await pool.query(
        `SELECT *
         FROM cabinet
         ORDER BY nom_cabinet ASC
         LIMIT 5`,
      );
    } else {
      const like = `%${q}%`;
      result = await pool.query(
        `SELECT *
         FROM cabinet
         WHERE nom_cabinet ILIKE $1
            OR adresse_cabinet ILIKE $1
            OR specialite_cabinet ILIKE $1
         ORDER BY nom_cabinet ASC`,
        [like],
      );
    }
    return res.json(result.rows);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.post("/cabinet/assign", async (req, res) => {
  try {
    const { id_user, id_cabinet, type_access = 1, etat = 1 } = req.body || {};
    const userId = Number(id_user);
    const cabinetId = Number(id_cabinet);
    if (!Number.isInteger(userId) || !Number.isInteger(cabinetId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    await pool.query(
      `INSERT INTO users_cabinet (id_user, id_cabinet, type_access, etat)
       VALUES ($1, $2, $3, $4)`,
      [userId, cabinetId, type_access, etat],
    );

    return res.status(201).json({ ok: true });
  } catch (err) {
    if (err && err.code === "23505") {
      return res.status(409).json({ error: "Already assigned." });
    }
    return res.status(500).json({ error: err.message });
  }
});

app.get("/patients", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM patients ORDER BY id ASC");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/patients/search", async (req, res) => {
  try {
    const q = String(req.query.q || "").trim();
    if (!q) return res.json([]);
    const like = `%${q}%`;
    const result = await pool.query(
      `SELECT *
       FROM patients
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

const port = process.env.PORT || 3001;
app.listen(port, () => {
  console.log(`API listening on http://localhost:${port}`);
});
