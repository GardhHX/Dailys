const { Router } = require('express');

const controller = require('../controllers/tugas.controller');

const router = Router();

// Route spesifik didaftarkan sebelum '/:id' supaya tidak ketangkep sebagai id.
router.get('/tugas/workload-mingguan', controller.workloadMingguan);

router.get('/tugas', controller.list);
router.post('/tugas', controller.create);
router.get('/tugas/:id', controller.getOne);
router.put('/tugas/:id', controller.update);
router.delete('/tugas/:id', controller.remove);

router.get('/tugas/:tugasId/checklist', controller.listChecklist);
router.post('/tugas/:tugasId/checklist', controller.createChecklist);
router.put('/tugas/:tugasId/checklist/:id', controller.updateChecklist);
router.delete('/tugas/:tugasId/checklist/:id', controller.removeChecklist);

module.exports = router;
