const { Router } = require('express');

const router = Router();

router.get('/health', (req, res) => {
  res.json({ data: { status: 'ok' }, error: null });
});

module.exports = router;
