const { z } = require('zod');
const { randomUUID } = require('crypto');

const { prisma } = require('../db/prisma');
const { LOCAL_USER_ID } = require('../constants');
const { ApiError, parseOrThrow } = require('../utils/validate');

const prioritasEnum = z.enum(['low', 'medium', 'high']);
const statusEnum = z.enum(['belum', 'progress', 'selesai']);

const createSchema = z.object({
  judul: z.string().min(1),
  mata_kuliah_id: z.string().optional(),
  deskripsi: z.string().optional(),
  deadline: z.coerce.date(),
  prioritas: prioritasEnum,
  estimasi_menit: z.number().int().optional(),
  reminder_offsets: z.array(z.number().int()).optional(),
});

const updateSchema = z.object({
  judul: z.string().min(1).optional(),
  mata_kuliah_id: z.string().nullable().optional(),
  deskripsi: z.string().nullable().optional(),
  deadline: z.coerce.date().optional(),
  prioritas: prioritasEnum.optional(),
  status: statusEnum.optional(),
  estimasi_menit: z.number().int().nullable().optional(),
  reminder_offsets: z.array(z.number().int()).optional(),
});

async function list(req, res, next) {
  try {
    const { status, mata_kuliah_id, prioritas, sort } = req.query;
    const where = { user_id: LOCAL_USER_ID, is_deleted: false };
    if (status) where.status = status;
    if (mata_kuliah_id) where.mata_kuliah_id = mata_kuliah_id;
    if (prioritas) where.prioritas = prioritas;

    const orderBy =
      sort === 'prioritas'
        ? { prioritas: 'asc' }
        : sort === 'mata_kuliah'
          ? { mata_kuliah: { nama: 'asc' } }
          : { deadline: 'asc' };

    const items = await prisma.tugas.findMany({ where, orderBy });
    res.json({ data: items, error: null });
  } catch (err) {
    next(err);
  }
}

async function getOne(req, res, next) {
  try {
    const item = await prisma.tugas.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
      include: { checklist: { where: { is_deleted: false }, orderBy: { urutan: 'asc' } } },
    });
    if (!item) throw new ApiError(404, 'NOT_FOUND', 'Tugas tidak ditemukan.');
    res.json({ data: item, error: null });
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  try {
    const body = parseOrThrow(createSchema, req.body);
    const created = await prisma.tugas.create({
      data: {
        id: randomUUID(),
        user_id: LOCAL_USER_ID,
        status: 'belum',
        reminder_offsets: body.reminder_offsets ?? [7, 3, 1, 0],
        ...body,
      },
    });
    res.status(201).json({ data: created, error: null });
  } catch (err) {
    next(err);
  }
}

async function update(req, res, next) {
  try {
    const body = parseOrThrow(updateSchema, req.body);
    const existing = await prisma.tugas.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Tugas tidak ditemukan.');

    const updated = await prisma.tugas.update({ where: { id: existing.id }, data: body });
    res.json({ data: updated, error: null });
  } catch (err) {
    next(err);
  }
}

async function remove(req, res, next) {
  try {
    const existing = await prisma.tugas.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Tugas tidak ditemukan.');

    await prisma.tugas.update({
      where: { id: existing.id },
      data: { is_deleted: true, deleted_at: new Date() },
    });
    res.json({ data: { id: existing.id }, error: null });
  } catch (err) {
    next(err);
  }
}

/// FR-6.12 — total tugas & estimasi jam per minggu.
async function workloadMingguan(req, res, next) {
  try {
    const { start_date, end_date } = parseOrThrow(
      z.object({ start_date: z.string(), end_date: z.string() }),
      req.query,
    );
    const start = new Date(`${start_date}T00:00:00.000Z`);
    const end = new Date(`${end_date}T23:59:59.999Z`);

    const items = await prisma.tugas.findMany({
      where: { user_id: LOCAL_USER_ID, is_deleted: false, deadline: { gte: start, lte: end } },
      select: { deadline: true, estimasi_menit: true },
    });

    res.json({
      data: {
        total_tugas: items.length,
        total_estimasi_menit: items.reduce((sum, t) => sum + (t.estimasi_menit ?? 0), 0),
      },
      error: null,
    });
  } catch (err) {
    next(err);
  }
}

// ---- Checklist sub-resource — FR-6.14 ----

async function listChecklist(req, res, next) {
  try {
    const items = await prisma.tugasChecklist.findMany({
      where: { tugas_id: req.params.tugasId, is_deleted: false },
      orderBy: { urutan: 'asc' },
    });
    res.json({ data: items, error: null });
  } catch (err) {
    next(err);
  }
}

async function createChecklist(req, res, next) {
  try {
    const body = parseOrThrow(z.object({ judul: z.string().min(1), urutan: z.number().int() }), req.body);
    const created = await prisma.tugasChecklist.create({
      data: { id: randomUUID(), tugas_id: req.params.tugasId, ...body },
    });
    res.status(201).json({ data: created, error: null });
  } catch (err) {
    next(err);
  }
}

async function updateChecklist(req, res, next) {
  try {
    const body = parseOrThrow(
      z.object({ judul: z.string().min(1).optional(), is_done: z.boolean().optional(), urutan: z.number().int().optional() }),
      req.body,
    );
    const existing = await prisma.tugasChecklist.findFirst({
      where: { id: req.params.id, tugas_id: req.params.tugasId, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Checklist item tidak ditemukan.');

    const updated = await prisma.tugasChecklist.update({ where: { id: existing.id }, data: body });
    res.json({ data: updated, error: null });
  } catch (err) {
    next(err);
  }
}

async function removeChecklist(req, res, next) {
  try {
    const existing = await prisma.tugasChecklist.findFirst({
      where: { id: req.params.id, tugas_id: req.params.tugasId, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Checklist item tidak ditemukan.');

    await prisma.tugasChecklist.update({
      where: { id: existing.id },
      data: { is_deleted: true, deleted_at: new Date() },
    });
    res.json({ data: { id: existing.id }, error: null });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  list,
  getOne,
  create,
  update,
  remove,
  workloadMingguan,
  listChecklist,
  createChecklist,
  updateChecklist,
  removeChecklist,
};
