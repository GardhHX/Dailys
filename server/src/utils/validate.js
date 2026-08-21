// Wrapper Zod tipis — parse body/query, lempar error terformat kalau invalid
// supaya controller tidak perlu try/catch berulang (API-SPEC.md format error).

class ApiError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

function parseOrThrow(schema, data) {
  const result = schema.safeParse(data);
  if (!result.success) {
    throw new ApiError(400, 'VALIDATION_ERROR', result.error.issues.map((i) => i.message).join('; '));
  }
  return result.data;
}

module.exports = { ApiError, parseOrThrow };
