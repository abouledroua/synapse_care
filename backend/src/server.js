import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import path from "path";

import { pool } from "./db.js";
import authRoutes from "./routes/auth.js";
import cabinetRoutes from "./routes/cabinet.js";
import patientRoutes from "./routes/patients.js";

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
    res.status(500).json({ ok: false, error: err.message });
  }
});

app.use("/auth", authRoutes);
app.use("/cabinet", cabinetRoutes);
app.use("/patients", patientRoutes);

const port = process.env.PORT || 3001;
app.listen(port, () => {
  console.log(`API listening on http://localhost:${port}`);
});
