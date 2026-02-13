import { pool } from "../db.js";

export const UserRole = Object.freeze({
  doctor: 1,
  assistant: 2,
  patient: 3,
});

export async function fetchUserById(userId) {
  const result = await pool.query(
    "SELECT id_user, role, is_verified FROM users WHERE id_user = $1 LIMIT 1",
    [userId],
  );
  return result.rowCount > 0 ? result.rows[0] : null;
}

export async function ensureVerifiedDoctor(userId) {
  const user = await fetchUserById(userId);
  if (!user) {
    return { ok: false, status: 404, error: "User not found." };
  }
  if (user.role !== UserRole.doctor || user.is_verified !== true) {
    return { ok: false, status: 403, error: "Doctor not verified." };
  }
  return { ok: true, user };
}

export async function ensureCabinetAdmin(cabinetId, userId) {
  const result = await pool.query(
    `SELECT 1
     FROM cabinet_admin
     WHERE id_cabinet = $1 AND id_user = $2 AND etat = 1
     LIMIT 1`,
    [cabinetId, userId],
  );
  if (result.rowCount === 0) {
    return { ok: false, status: 403, error: "Not authorized." };
  }
  return { ok: true };
}

export async function ensurePlatformAdmin(userId) {
  const result = await pool.query(
    `SELECT 1
     FROM platform_admin
     WHERE id_user = $1 AND etat = 1
     LIMIT 1`,
    [userId],
  );
  if (result.rowCount === 0) {
    return { ok: false, status: 403, error: "Platform admin required." };
  }
  return { ok: true };
}

export async function ensureAffiliatedUser(cabinetId, userId) {
  const result = await pool.query(
    `SELECT 1
     FROM users_cabinet
     WHERE id_cabinet = $1 AND id_user = $2 AND status = 1
     LIMIT 1`,
    [cabinetId, userId],
  );
  if (result.rowCount === 0) {
    return { ok: false, status: 403, error: "Not affiliated with this clinic." };
  }
  return { ok: true };
}

export async function ensureCabinetStaff(cabinetId, userId) {
  const affiliationCheck = await ensureAffiliatedUser(cabinetId, userId);
  if (!affiliationCheck.ok) {
    return affiliationCheck;
  }

  const user = await fetchUserById(userId);
  if (!user) {
    return { ok: false, status: 404, error: "User not found." };
  }
  if (user.role !== UserRole.doctor && user.role !== UserRole.assistant) {
    return { ok: false, status: 403, error: "Only clinic staff can perform this action." };
  }
  return { ok: true, user };
}
