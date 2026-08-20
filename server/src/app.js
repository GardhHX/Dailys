const express = require('express');
const cors = require('cors');

const { authMiddleware } = require('./middleware/auth');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');
const healthRoutes = require('./routes/health.routes');

const app = express();

app.use(cors());
app.use(express.json());

// /health tidak perlu auth (API-SPEC.md Section 0).
app.use('/api/v1', healthRoutes);

// Semua route lain di bawah /api/v1 wajib token (API-SPEC.md "Auth").
app.use('/api/v1', authMiddleware);

// Route per resource ditambahkan di sini seiring Phase 1-6 (lihat PLAN.md).

app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
