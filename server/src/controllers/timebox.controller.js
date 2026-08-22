const { z } = require('zod');
const { randomUUID } = require('crypto');

const { prisma } = require('../db/prisma');
const { LOCAL_USER_ID } = require('../constants');
const { ApiError, parseOrThrow } = require('../utils/validate');

const hariEnum = z.enum(['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu']);
const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;

const createSchema = z
  .object({
    tugas_id: z.string().optional(),
    habit_id: z.string().optional(),
    judul: z.string().min(1),
    kategori: z.string().min(1),
    start_time: z.string().regex(timeRegex, 'Format jam HH:mm'),
    end_time: z.string().regex(timeRegex, 'Format jam HH:mm'),
    hari: hariEnum.optional(),
    tanggal_spesifik: z.coerce.date().optional(),
    is_recurring: z.boolean(),
  })
  .refine((b) => (b.is_recurring ? !!b.hari : !!b.tanggal_spesifik), {
    message: 'Template mingguan wajib isi hari; block ad-hoc wajib isi tanggal_spesifik.',
  });

const updateSchema = z.object({
  tugas_id: z.string().nullable().optional(),
  habit_id: z.string().nullable().optional(),
  judul: z.string().min(1).optional(),
  kategori: z.string().min(1).optional(),
  start_time: z.string().regex(timeRegex, 'Format jam HH:mm').optional(),
  end_time: z.string().regex(timeRegex, 'Format jam HH:mm').optional(),
  hari: hariEnum.nullable().optional(),
  tanggal_spesifik: z.coerce.date().nullable().optional(),
  is_recurring: z.boolean().optional(),
});

function toMinutes(hm) {
  const [h, m] = hm.split(':').map(Number);
  return h * 60 + m;
}

/// FR-3.9 — cek bentrok terhadap block lain yang tampil di `hari`/tanggal
/// yang sama, dipanggil sebelum create/update.
async function findBentrok({ hari, tanggalSpesifik, startTime, endTime, excludeId }) {
  const where = {
    user_id: LOCAL_USER_ID,
    is_deleted: false,
    id: excludeId ? { not: excludeId } : undefined,
    ...(hari ? { hari } : { tanggal_spesifik: tanggalSpesifik }),
  };
  const candidates = await prisma.timeboxSchedule.findMany({ where });
  const startMin = toMinutes(startTime);
  const endMin = toMinutes(endTime);
  return candidates.filter((c) => toMinutes(c.start_time) < endMin && toMinutes(c.end_time) > startMin);
}

async function list(req, res, next) {
  try {
    const { hari, tanggal_spesifik } = req.query;
    const where = { user_id: LOCAL_USER_ID, is_deleted: false };
    if (hari) where.hari = hari;
    if (tanggal_spesifik) where.tanggal_spesifik = new Date(`${tanggal_spesifik}T00:00:00.000Z`);

    const items = await prisma.timeboxSchedule.findMany({ where });
    res.json({ data: items, error: null });
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  try {
    const body = parseOrThrow(createSchema, req.body);
    const bentrok = await findBentrok({
      hari: body.hari,
      tanggalSpesifik: body.tanggal_spesifik,
      startTime: body.start_time,
      endTime: body.end_time,
    });

    const created = await prisma.timeboxSchedule.create({
      data: { id: randomUUID(), user_id: LOCAL_USER_ID, ...body },
    });
    res.status(201).json({
      data: created,
      error: null,
      ...(bentrok.length ? { warning: { bentrok_with: bentrok } } : {}),
    });
  } catch (err) {
    next(err);
  }
}

async function update(req, res, next) {
  try {
    const body = parseOrThrow(updateSchema, req.body);
    const existing = await prisma.timeboxSchedule.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Timebox block tidak ditemukan.');

    const updated = await prisma.timeboxSchedule.update({ where: { id: existing.id }, data: body });
    res.json({ data: updated, error: null });
  } catch (err) {
    next(err);
  }
}

async function remove(req, res, next) {
  try {
    const existing = await prisma.timeboxSchedule.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Timebox block tidak ditemukan.');

    await prisma.timeboxSchedule.update({
      where: { id: existing.id },
      data: { is_deleted: true, deleted_at: new Date() },
    });
    res.json({ data: { id: existing.id }, error: null });
  } catch (err) {
    next(err);
  }
}

/// FR-3.12 — nonaktifkan sementara 1 slot template tanpa hapus permanen.
async function toggleActive(req, res, next) {
  try {
    const body = parseOrThrow(z.object({ is_active: z.boolean() }), req.body);
    const existing = await prisma.timeboxSchedule.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Timebox block tidak ditemukan.');

    const updated = await prisma.timeboxSchedule.update({
      where: { id: existing.id },
      data: { is_active: body.is_active },
    });
    res.json({ data: updated, error: null });
  } catch (err) {
    next(err);
  }
}

/// FR-3.11 — duplikasi block ke hari lain (salinan baru, independen).
async function duplicate(req, res, next) {
  try {
    const body = parseOrThrow(z.object({ target_hari: hariEnum }), req.body);
    const source = await prisma.timeboxSchedule.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!source) throw new ApiError(404, 'NOT_FOUND', 'Timebox block tidak ditemukan.');

    const created = await prisma.timeboxSchedule.create({
      data: {
        id: randomUUID(),
        user_id: LOCAL_USER_ID,
        tugas_id: source.tugas_id,
        habit_id: source.habit_id,
        judul: source.judul,
        kategori: source.kategori,
        start_time: source.start_time,
        end_time: source.end_time,
        is_recurring: source.is_recurring,
        hari: body.target_hari,
        is_active: true,
      },
    });
    res.status(201).json({ data: created, error: null });
  } catch (err) {
    next(err);
  }
}

/// FR-3.7, FR-3.14 — dari prompt konfirmasi block yang waktunya sudah lewat.
/// Kalau `masih_berlaku` (dieksekusi), otomatis generate Activity (source:
/// timebox) sesuai daftar auto-trigger di API-SPEC.md Section 8.
async function markStatus(req, res, next) {
  try {
    const body = parseOrThrow(
      z.object({
        status: z.enum(['missed', 'reschedule', 'masih_berlaku']),
        new_date: z.coerce.date().optional(),
      }),
      req.body,
    );
    const block = await prisma.timeboxSchedule.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!block) throw new ApiError(404, 'NOT_FOUND', 'Timebox block tidak ditemukan.');

    if (body.status === 'reschedule') {
      if (!body.new_date) throw new ApiError(400, 'VALIDATION_ERROR', 'new_date wajib diisi untuk reschedule.');
      await prisma.timeboxSchedule.update({
        where: { id: block.id },
        data: { tanggal_spesifik: body.new_date, is_recurring: false, hari: null },
      });
    }

    let activity = null;
    if (body.status === 'masih_berlaku') {
      const today = new Date();
      const dateStr = today.toISOString().split('T')[0];
      const [startH, startM] = block.start_time.split(':').map(Number);
      const [endH, endM] = block.end_time.split(':').map(Number);
      activity = await prisma.activity.create({
        data: {
          id: randomUUID(),
          user_id: LOCAL_USER_ID,
          judul: block.judul,
          kategori: block.kategori,
          start_time: new Date(`${dateStr}T${String(startH).padStart(2, '0')}:${String(startM).padStart(2, '0')}:00.000Z`),
          end_time: new Date(`${dateStr}T${String(endH).padStart(2, '0')}:${String(endM).padStart(2, '0')}:00.000Z`),
          status: 'selesai',
          source: 'timebox',
          source_id: block.id,
        },
      });
    }

    res.json({ data: { block_id: block.id, status: body.status, activity }, error: null });
  } catch (err) {
    next(err);
  }
}

module.exports = { list, create, update, remove, toggleActive, duplicate, markStatus };
