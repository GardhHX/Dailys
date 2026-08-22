const { Router } = require('express');

const controller = require('../controllers/timebox.controller');

const router = Router();

router.get('/timebox', controller.list);
router.post('/timebox', controller.create);
router.put('/timebox/:id', controller.update);
router.delete('/timebox/:id', controller.remove);
router.put('/timebox/:id/toggle-active', controller.toggleActive);
router.post('/timebox/:id/duplicate', controller.duplicate);
router.post('/timebox/:id/mark-status', controller.markStatus);

module.exports = router;
