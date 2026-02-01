import { Router } from "express";
import bcrypt from "bcryptjs";
import fs from "fs/promises";
import path from "path";

import { pool } from "../db.js";

const router = Router();

const PHOTOS_DIR = path.join(process.cwd(), "IMAGES", "DOCTEUR");
const ALLOWED_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);

async function ensurePhotosDir() {
  await fs.mkdir(PHOTOS_DIR, { recursive: true });
}

router.post("/signup", async (req, res) => {
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

router.post("/login", async (req, res) => {
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

export default router;
