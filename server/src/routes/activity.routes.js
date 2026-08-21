const { Router } = require('express');

const controller = require('../controllers/activity.controller');

const router = Router();

// Route spesifik didaftarkan sebelum '/:id' supaya tidak ketangkep sebagai id.
router.post('/activity/bulk-complete', controller.bulkComplete);
router.post('/activity/bulk-reschedule', controller.bulkReschedule);
router.get('/activity/completion-rate', controller.completionRate);

router.get('/activity', controller.list);
router.post('/activity', controller.create);
router.get('/activity/:id', controller.getOne);
router.put('/activity/:id', controller.update);
router.delete('/activity/:id', controller.remove);

module.exports = router;
