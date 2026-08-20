// Auth sederhana — token statis di header Authorization: Bearer <token>.
// Keputusan: JWT long-lived / API key statis, single-user, tanpa refresh
// token (CLAUDE.md Section 6.3). Dibandingkan token statis di sini masih
// dicek per-request supaya server tidak terbuka bebas kalau domain ketahuan.

function authMiddleware(req, res, next) {
  const header = req.headers.authorization;
  const token = header?.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token || token !== process.env.AUTH_TOKEN) {
    return res.status(401).json({
      data: null,
      error: { code: 'UNAUTHORIZED', message: 'Token tidak valid atau tidak ada.' },
    });
  }

  next();
}

module.exports = { authMiddleware };
