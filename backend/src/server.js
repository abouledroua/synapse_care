import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import path from "path";

import { pool } from "./db.js";
import { ensureAllClinicDatabasesSchema } from "./services/clinic_db_service.js";
import authRoutes from "./routes/auth.js";
import cabinetRoutes from "./routes/cabinet.js";
import patientRoutes from "./routes/patients.js";
import rdvRoutes from "./routes/rdv.js";
import { sendServerError } from "./utils/api_error.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use(
  "/photos",
  express.static(path.join(process.cwd(), "IMAGES", "DOCTEUR")),
);
app.use(
  "/IMAGES/CABINET",
  express.static(path.join(process.cwd(), "IMAGES", "CABINET")),
);
app.use(
  "/IMAGES/PATIENT",
  express.static(path.join(process.cwd(), "IMAGES", "PATIENT")),
);

app.get("/health", async (req, res) => {
  try {
    const result = await pool.query("SELECT 1 AS ok");
    res.json({ ok: true, db: result.rows[0].ok });
  } catch (err) {
    return sendServerError(res, err);
  }
});

app.use("/auth", authRoutes);
app.use("/cabinet", cabinetRoutes);
app.use("/patients", patientRoutes);
app.use("/rdv", rdvRoutes);

const port = process.env.PORT || 3001;
app.listen(port, () => {
  console.log(`API listening on http://localhost:${port}`);
});

// Ensure every clinic database has the clinic-local schema (rdv, consultation, clinic_patient).
ensureAllClinicDatabasesSchema(pool).catch((err) => {
  console.error("Failed to ensure clinic schemas:", err);
});
