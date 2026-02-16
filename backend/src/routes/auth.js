import { Router } from "express";
import bcrypt from "bcryptjs";
import crypto from "crypto";
import fs from "fs/promises";
import path from "path";
import nodemailer from "nodemailer";

import { pool } from "../db.js";
import { UserRole } from "../middleware/authorization.js";
import { sendServerError } from "../utils/api_error.js";

const router = Router();

const PHOTOS_DIR = path.join(process.cwd(), "IMAGES", "DOCTEUR");
const ALLOWED_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);
const RESET_CODE_TTL_MINUTES = Number(process.env.RESET_CODE_TTL_MINUTES || 15);

function createMailer() {
  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT || 587);
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  if (!host || !user || !pass) {
    return null;
  }
  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: { user, pass },
  });
}

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
      `INSERT INTO users (fullname, email, phone, password, role, speciality, photo_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id_user, fullname, email, phone, role, speciality, photo_url`,
      [
        fullname,
        email,
        phone || null,
        passwordHash,
        UserRole.doctor,
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
        "UPDATE users SET photo_url = $1 WHERE id_user = $2 RETURNING id_user, fullname, email, phone, role, speciality, photo_url",
        [photoUrl, user.id_user],
      );
      return res.status(201).json(updated.rows[0]);
    }

    return res.status(201).json(user);
  } catch (err) {
    return sendServerError(res, err);
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
      "SELECT id_user, fullname, email, phone, password, role, speciality, photo_url FROM users WHERE email = $1 LIMIT 1",
      [email],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "User not found." });
    }

    const user = result.rows[0];
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({ error: "Invalid password." });
    }

    const platformAdminResult = await pool.query(
      `SELECT 1
       FROM platform_admin
       WHERE id_user = $1 AND etat = 1
       LIMIT 1`,
      [user.id_user],
    );
    user.is_platform_admin = platformAdminResult.rowCount > 0;

    delete user.password;
    return res.status(200).json(user);
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/forgot", async (req, res) => {
  try {
    const { email } = req.body || {};
    if (!email) {
      return res.status(400).json({ error: "Email is required." });
    }

    const userResult = await pool.query(
      "SELECT id_user, email FROM users WHERE email = $1 LIMIT 1",
      [email.trim()],
    );
    if (userResult.rowCount === 0) {
      return res.status(404).json({ error: "Email does not exist." });
    }

    const mailer = createMailer();
    if (!mailer) {
      return res.status(500).json({ error: "Email service not configured." });
    }

    const code = crypto.randomInt(0, 1000000).toString().padStart(6, "0");
    const codeHash = await bcrypt.hash(code, 10);
    const expiresAt = new Date(Date.now() + RESET_CODE_TTL_MINUTES * 60 * 1000);

    await pool.query(
      `INSERT INTO password_reset_codes (id_user, code_hash, expires_at)
       VALUES ($1, $2, $3)`,
      [userResult.rows[0].id_user, codeHash, expiresAt],
    );

    const from = process.env.SMTP_FROM || process.env.SMTP_USER;
    await mailer.sendMail({
      from,
      to: email.trim(),
      subject: "Password reset code",
      text: `Your password reset code is: ${code}`,
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/verify-reset", async (req, res) => {
  try {
    const { email, code } = req.body || {};
    if (!email || !code) {
      return res.status(400).json({ error: "Email and code are required." });
    }

    const userResult = await pool.query(
      "SELECT id_user FROM users WHERE email = $1 LIMIT 1",
      [email.trim()],
    );
    if (userResult.rowCount === 0) {
      return res.status(404).json({ error: "Email does not exist." });
    }

    const resetResult = await pool.query(
      `SELECT id_reset, code_hash, expires_at, used_at
       FROM password_reset_codes
       WHERE id_user = $1 AND used_at IS NULL
       ORDER BY created_at DESC
       LIMIT 1`,
      [userResult.rows[0].id_user],
    );
    if (resetResult.rowCount === 0) {
      return res.status(400).json({ error: "Invalid or expired code." });
    }

    const reset = resetResult.rows[0];
    if (new Date(reset.expires_at) < new Date()) {
      return res.status(400).json({ error: "Invalid or expired code." });
    }

    const match = await bcrypt.compare(code, reset.code_hash);
    if (!match) {
      return res.status(400).json({ error: "Invalid or expired code." });
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const { email, code, new_password } = req.body || {};
    if (!email || !code || !new_password) {
      return res.status(400).json({ error: "Email, code, and new password are required." });
    }

    const userResult = await pool.query(
      "SELECT id_user FROM users WHERE email = $1 LIMIT 1",
      [email.trim()],
    );
    if (userResult.rowCount === 0) {
      return res.status(404).json({ error: "Email does not exist." });
    }

    const resetResult = await pool.query(
      `SELECT id_reset, code_hash, expires_at, used_at
       FROM password_reset_codes
       WHERE id_user = $1 AND used_at IS NULL
       ORDER BY created_at DESC
       LIMIT 1`,
      [userResult.rows[0].id_user],
    );
    if (resetResult.rowCount === 0) {
      return res.status(400).json({ error: "Invalid or expired code." });
    }

    const reset = resetResult.rows[0];
    if (new Date(reset.expires_at) < new Date()) {
      return res.status(400).json({ error: "Invalid or expired code." });
    }

    const match = await bcrypt.compare(code, reset.code_hash);
    if (!match) {
      return res.status(400).json({ error: "Invalid or expired code." });
    }

    const rounds = Number(process.env.BCRYPT_ROUNDS || 10);
    const passwordHash = await bcrypt.hash(new_password, rounds);

    await pool.query(
      "UPDATE users SET password = $1 WHERE id_user = $2",
      [passwordHash, userResult.rows[0].id_user],
    );

    await pool.query(
      "UPDATE password_reset_codes SET used_at = NOW() WHERE id_reset = $1",
      [reset.id_reset],
    );

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/verification/request", async (req, res) => {
  try {
    const { id_user, documents = [] } = req.body || {};
    const userId = Number(id_user);
    if (!Number.isInteger(userId)) {
      return res.status(400).json({ error: "Invalid user id." });
    }

    const userResult = await pool.query(
      "SELECT id_user, role FROM users WHERE id_user = $1",
      [userId],
    );
    if (userResult.rowCount === 0) {
      return res.status(404).json({ error: "User not found." });
    }
    if (userResult.rows[0].role !== UserRole.doctor) {
      return res.status(403).json({ error: "Only doctors can be verified." });
    }

    await pool.query(
      `UPDATE users
       SET verification_status = 1,
           is_verified = false
       WHERE id_user = $1`,
      [userId],
    );

    if (Array.isArray(documents)) {
      for (const doc of documents) {
        const docType = doc?.doc_type;
        const docUrl = doc?.doc_url;
        if (!docType || !docUrl) continue;
        await pool.query(
          `INSERT INTO doctor_documents (id_user, doc_type, doc_url)
           VALUES ($1, $2, $3)`,
          [userId, docType, docUrl],
        );
      }
    }

    return res.status(200).json({ ok: true, status: "pending" });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.get("/verification/pending", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id_user, fullname, email, phone, role, verification_status
       FROM users
       WHERE role = $1 AND verification_status = 1
       ORDER BY id_user DESC`,
      [UserRole.doctor],
    );
    return res.status(200).json(result.rows);
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/verification/approve", async (req, res) => {
  try {
    const { id_admin, id_user } = req.body || {};
    const adminId = Number(id_admin);
    const userId = Number(id_user);
    if (!Number.isInteger(adminId) || !Number.isInteger(userId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    await pool.query(
      `UPDATE users
       SET verification_status = 2,
           is_verified = true,
           verified_at = NOW(),
           verified_by = $2
       WHERE id_user = $1`,
      [userId, adminId],
    );

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
  }
});

router.post("/verification/reject", async (req, res) => {
  try {
    const { id_admin, id_user, notes } = req.body || {};
    const adminId = Number(id_admin);
    const userId = Number(id_user);
    if (!Number.isInteger(adminId) || !Number.isInteger(userId)) {
      return res.status(400).json({ error: "Invalid ids." });
    }

    await pool.query(
      `UPDATE users
       SET verification_status = 3,
           is_verified = false,
           verification_notes = $3,
           verified_at = NOW(),
           verified_by = $2
       WHERE id_user = $1`,
      [userId, adminId, notes || null],
    );

    return res.status(200).json({ ok: true });
  } catch (err) {
    return sendServerError(res, err);
  }
});

export default router;
