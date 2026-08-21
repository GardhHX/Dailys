const { z } = require('zod');
const { randomUUID } = require('crypto');

const { prisma } = require('../db/prisma');
const { LOCAL_USER_ID } = require('../constants');
const { ApiError, parseOrThrow } = require('../utils/validate');

const activityStatuses = ['belum_mulai', 'berjalan', 'selesai', 'dilewati'];

const createSchema = z.object({
  judul: z.string().min(1),
  kategori: z.string().min(1),
  start_time: z.coerce.date().optional(),
  end_time: z.coerce.date().optional(),
  is_all_day: z.boolean().optional(),
  is_recurring: z.boolean().optional(),
  recurring_days: z.array(z.number().int()).optional(),
  recurring_end_date: z.coerce.date().optional(),
  catatan: z.string().optional(),
});

const updateSchema = z.object({
  judul: z.string().min(1).optional(),
  kategori: z.string().min(1).optional(),
  start_time: z.coerce.date().nullable().optional(),
  end_time: z.coerce.date().nullable().optional(),
  is_all_day: z.boolean().optional(),
  status: z.enum(activityStatuses).optional(),
  is_recurring: z.boolean().optional(),
  recurring_days: z.array(z.number().int()).nullable().optional(),
  recurring_end_date: z.coerce.date().nullable().optional(),
  catatan: z.string().nullable().optional(),
});

function dayRange(dateStr) {
  const start = new Date(`${dateStr}T00:00:00.000Z`);
  const end = new Date(start.getTime() + 24 * 60 * 60 * 1000);
  return { start, end };
}

/// FR-1.8 — cari activity lain yang overlap dengan rentang [start, end).
async function findOverlaps({ start, end, excludeId }) {
  return prisma.activity.findMany({
    where: {
      is_deleted: false,
      is_all_day: false,
      id: excludeId ? { not: excludeId } : undefined,
      start_time: { lt: end },
      end_time: { gt: start },
    },
  });
}

async function list(req, res, next) {
  try {
    const { date, start_date, end_date, kategori } = req.query;
    const where = { user_id: LOCAL_USER_ID, is_deleted: false };

    if (date) {
      const { start, end } = dayRange(date);
      where.start_time = { gte: start, lt: end };
    } else if (start_date || end_date) {
      where.start_time = {};
      if (start_date) where.start_time.gte = dayRange(start_date).start;
      if (end_date) where.start_time.lt = dayRange(end_date).end;
    }
    if (kategori) where.kategori = kategori;

    const limit = Math.min(Number(req.query.limit) || 50, 200);
    const offset = Number(req.query.offset) || 0;

    const items = await prisma.activity.findMany({
      where,
      orderBy: { start_time: 'asc' },
      take: limit,
      skip: offset,
    });
    res.json({ data: items, error: null });
  } catch (err) {
    next(err);
  }
}

async function getOne(req, res, next) {
  try {
    const item = await prisma.activity.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!item) throw new ApiError(404, 'NOT_FOUND', 'Activity tidak ditemukan.');
    res.json({ data: item, error: null });
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  try {
    const body = parseOrThrow(createSchema, req.body);

    let warning;
    if (!body.is_all_day && body.start_time && body.end_time) {
      const overlaps = await findOverlaps({ start: body.start_time, end: body.end_time });
      if (overlaps.length > 0) warning = { overlap_with: overlaps.map((o) => o.id) };
    }

    const created = await prisma.activity.create({
      data: {
        id: randomUUID(),
        user_id: LOCAL_USER_ID,
        judul: body.judul,
        kategori: body.kategori,
        start_time: body.start_time,
        end_time: body.end_time,
        is_all_day: body.is_all_day ?? false,
        status: 'belum_mulai',
        is_recurring: body.is_recurring ?? false,
        recurring_days: body.recurring_days,
        recurring_end_date: body.recurring_end_date,
        source: 'manual',
        catatan: body.catatan,
      },
    });

    res.status(201).json({ data: { ...created, warning }, error: null });
  } catch (err) {
    next(err);
  }
}

async function update(req, res, next) {
  try {
    const body = parseOrThrow(updateSchema, req.body);
    const existing = await prisma.activity.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Activity tidak ditemukan.');

    const updated = await prisma.activity.update({
      where: { id: existing.id },
      data: body,
    });
    res.json({ data: updated, error: null });
  } catch (err) {
    next(err);
  }
}

async function remove(req, res, next) {
  try {
    const existing = await prisma.activity.findFirst({
      where: { id: req.params.id, user_id: LOCAL_USER_ID, is_deleted: false },
    });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Activity tidak ditemukan.');

    // Soft delete — jangan pernah hard delete (CLAUDE.md Section 4).
    await prisma.activity.update({
      where: { id: existing.id },
      data: { is_deleted: true, deleted_at: new Date() },
    });
    res.json({ data: { id: existing.id }, error: null });
  } catch (err) {
    next(err);
  }
}

async function bulkComplete(req, res, next) {
  try {
    const { date } = parseOrThrow(z.object({ date: z.string() }), req.body);
    const { start, end } = dayRange(date);
    const result = await prisma.activity.updateMany({
      where: {
        user_id: LOCAL_USER_ID,
        is_deleted: false,
        start_time: { gte: start, lt: end },
        status: { not: 'selesai' },
      },
      data: { status: 'selesai' },
    });
    res.json({ data: { updated: result.count }, error: null });
  } catch (err) {
    next(err);
  }
}

async function bulkReschedule(req, res, next) {
  try {
    const { date, target_date } = parseOrThrow(
      z.object({ date: z.string(), target_date: z.string() }),
      req.body,
    );
    const { start, end } = dayRange(date);
    const deltaMs = dayRange(target_date).start.getTime() - start.getTime();

    const pending = await prisma.activity.findMany({
      where: {
        user_id: LOCAL_USER_ID,
        is_deleted: false,
        start_time: { gte: start, lt: end },
        status: { not: 'selesai' },
      },
    });

    await prisma.$transaction(
      pending.map((a) =>
        prisma.activity.update({
          where: { id: a.id },
          data: {
            start_time: a.start_time ? new Date(a.start_time.getTime() + deltaMs) : null,
            end_time: a.end_time ? new Date(a.end_time.getTime() + deltaMs) : null,
          },
        }),
      ),
    );
    res.json({ data: { updated: pending.length }, error: null });
  } catch (err) {
    next(err);
  }
}

async function completionRate(req, res, next) {
  try {
    const { date } = parseOrThrow(z.object({ date: z.string() }), req.query);
    const { start, end } = dayRange(date);
    const items = await prisma.activity.findMany({
      where: { user_id: LOCAL_USER_ID, is_deleted: false, start_time: { gte: start, lt: end } },
      select: { status: true },
    });
    const completed = items.filter((a) => a.status === 'selesai').length;
    res.json({
      data: { completed, total: items.length, rate: items.length === 0 ? 0 : completed / items.length },
      error: null,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { list, getOne, create, update, remove, bulkComplete, bulkReschedule, completionRate };
