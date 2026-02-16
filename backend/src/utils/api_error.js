const DB_UNAVAILABLE_CODES = new Set([
  "08000",
  "08001",
  "08003",
  "08004",
  "08006",
  "08P01",
  "57P01",
  "57P02",
  "57P03",
  "53300",
]);

function classifyError(err) {
  const code = `${err?.code ?? ""}`.trim();
  if (code === "3D000") {
    return {
      status: 503,
      code: "DB_NOT_FOUND",
      error: "Database not found.",
    };
  }
  if (DB_UNAVAILABLE_CODES.has(code)) {
    return {
      status: 503,
      code: "DB_UNAVAILABLE",
      error: "Database unavailable.",
    };
  }
  return {
    status: 500,
    code: "INTERNAL_ERROR",
    error: err?.message || "Internal server error.",
  };
}

export function sendServerError(res, err) {
  const payload = classifyError(err);
  return res.status(payload.status).json({ error: payload.error, code: payload.code });
}
