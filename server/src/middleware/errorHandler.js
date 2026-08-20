// Response format konsisten { data, error } — API-SPEC.md "Konvensi Umum".

function notFoundHandler(req, res) {
  res.status(404).json({
    data: null,
    error: { code: 'NOT_FOUND', message: `Route ${req.method} ${req.path} tidak ditemukan.` },
  });
}

// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  console.error(err);
  const status = err.status ?? 500;
  res.status(status).json({
    data: null,
    error: {
      code: err.code ?? 'INTERNAL_ERROR',
      message: err.message ?? 'Terjadi kesalahan pada server.',
    },
  });
}

module.exports = { notFoundHandler, errorHandler };
