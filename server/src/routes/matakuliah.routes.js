const { Router } = require('express');

const controller = require('../controllers/matakuliah.controller');

const router = Router();

router.get('/matakuliah', controller.list);
router.post('/matakuliah', controller.create);
router.put('/matakuliah/:id', controller.update);
router.delete('/matakuliah/:id', controller.remove);

module.exports = router;
