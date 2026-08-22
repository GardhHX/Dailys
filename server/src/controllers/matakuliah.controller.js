const { z } = require('zod');
const { randomUUID } = require('crypto');

const { prisma } = require('../db/prisma');
const { LOCAL_USER_ID } = require('../constants');
const { ApiError, parseOrThrow } = require('../utils/validate');

const createSchema = z.object({
  nama: z.string().min(1),
  dosen: z.string().optional(),
  sks: z.number().int().optional(),
  semester: z.string().optional(),
  warna: z.string().min(1),
});

const updateSchema = createSchema.partial();

async function list(req, res, next) {
  try {
    const items = await prisma.mataKuliah.findMany({
      where: { user_id: LOCAL_USER_ID, is_deleted: false },
      orderBy: { nama: 'asc' },
    });
    res.json({ data: items, error: null });
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  try {
    const body = parseOrThrow(createSchema, req.body);
    const created = await prisma.mataKuliah.create({
      data: { id: randomUUID(), user_id: LOCAL_USER_ID, ...body },
    });
    res.status(201).json({ data: created, error: null });
  } catch (err) {
    next(err);
  }
}

async function update(req, res, next) {
  try {
    const body = parseOrThrow(updateSchema, req.body);
    const existing = await prisma.mataKuliah.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Mata kuliah tidak ditemukan.');

    const updated = await prisma.mataKuliah.update({ where: { id: existing.id }, data: body });
    res.json({ data: updated, error: null });
  } catch (err) {
    next(err);
  }
}

async function remove(req, res, next) {
  try {
    const existing = await prisma.mataKuliah.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Mata kuliah tidak ditemukan.');

    await prisma.mataKuliah.update({
      where: { id: existing.id },
      data: { is_deleted: true, deleted_at: new Date() },
    });
    res.json({ data: { id: existing.id }, error: null });
  } catch (err) {
    next(err);
  }
}

module.exports = { list, create, update, remove };
