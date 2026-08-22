const express = require('express');
const cors = require('cors');

const { authMiddleware } = require('./middleware/auth');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');
const healthRoutes = require('./routes/health.routes');
const activityRoutes = require('./routes/activity.routes');
const matakuliahRoutes = require('./routes/matakuliah.routes');
const tugasRoutes = require('./routes/tugas.routes');

const app = express();

app.use(cors());
app.use(express.json());

// /health tidak perlu auth (API-SPEC.md Section 0).
app.use('/api/v1', healthRoutes);

// Semua route lain di bawah /api/v1 wajib token (API-SPEC.md "Auth").
app.use('/api/v1', authMiddleware);

app.use('/api/v1', activityRoutes);
app.use('/api/v1', matakuliahRoutes);
app.use('/api/v1', tugasRoutes);

// Route per resource lain ditambahkan di sini seiring Phase 3-6 (lihat PLAN.md).

app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
