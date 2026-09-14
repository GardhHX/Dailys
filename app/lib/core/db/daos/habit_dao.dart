import 'package:drift/drift.dart';

import '../../ids/deterministic_id.dart';
import '../../projections/streak.dart';
import '../../time/local_date.dart';
import '../database.dart';
import '../tables/enums.dart';
import '../tables/m1_tables.dart';
import '../tables/m4_habit_tables.dart';

part 'habit_dao.g.dart';

/// Thrown by HabitDao commands whose preconditions the schema mandates
/// (schema 11.1): effective dates must be today or later, target_hari must be
/// non-empty.
class HabitCommandException implements Exception {
  HabitCommandException(this.message);
  final String message;
  @override
  String toString() => 'HabitCommandException: $message';
}

/// Habit + HabitSchedule + HabitLog access (schema 11, 11.1, 11.2). Also
/// touches `Activity` directly (like `PomodoroDao`/materializer code) so
/// HabitLog corrections keep the derived Activity consistent in the same
/// transaction (FR-5.15).
@DriftAccessor(tables: [Habit, HabitSchedule, HabitLog, Activity])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  // --- Habit ---

  /// Active (non-deleted) habits for [userId], ordered by `urutan` (schema
  /// 11 index). Callers split Aktif/Dijeda via `is_archived` and Hari
  /// ini/Habit lainnya via the schedule active on the viewed date.
  Stream<List<HabitRow>> watchHabits(String userId) => (select(habit)
        ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.urutan)]))
      .watch();

  Future<HabitRow?> getHabit(String id) =>
      (select(habit)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> _nextUrutan(String userId) async {
    final rows = await (select(habit)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false)))
        .get();
    if (rows.isEmpty) return 0;
    return rows.map((r) => r.urutan).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// FR-5.1: create Habit + its first HabitSchedule (`effective_from=today`,
  /// `state=active`) in one transaction (API-SPEC 9.6 "Create Habit
  /// menghasilkan Habit dan HabitSchedule pertama").
  Future<String> createHabit({
    required String userId,
    required String nama,
    required String warna,
    String? icon,
    required Set<int> targetHari,
    int maxIzinPerMinggu = 1,
    required LocalDate today,
    DateTime? now,
  }) async {
    if (nama.trim().isEmpty) {
      throw HabitCommandException('Nama habit wajib diisi');
    }
    if (targetHari.isEmpty) {
      throw HabitCommandException('Target hari wajib minimal satu');
    }
    if (maxIzinPerMinggu < 0) {
      throw HabitCommandException('Batas izin tidak boleh negatif');
    }
    final ts = now ?? DateTime.now().toUtc();
    final habitId = DeterministicId.v4();
    await transaction(() async {
      final urutan = await _nextUrutan(userId);
      await into(habit).insert(HabitCompanion.insert(
        id: habitId,
        createdAt: ts,
        updatedAt: ts,
        userId: userId,
        nama: nama.trim(),
        warna: warna,
        icon: Value(icon),
        urutan: urutan,
      ));
      await into(habitSchedule).insert(HabitScheduleCompanion.insert(
        id: DeterministicId.habitSchedule(habitId, today.toYmd()),
        createdAt: ts,
        updatedAt: ts,
        habitId: habitId,
        effectiveFrom: today.toYmd(),
        targetHari: targetHari.toList()..sort(),
        maxIzinPerMinggu: Value(maxIzinPerMinggu),
        state: HabitScheduleState.active,
      ));
    });
    return habitId;
  }

  /// Edits `nama`/`warna`/`icon` only — no schedule change (API-SPEC 9.6:
  /// "schedule=null hanya untuk update nama/warna/icon/urutan").
  Future<void> updateDefinition(
    String id, {
    String? nama,
    String? warna,
    Object? icon = _unset,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(habit)..where((t) => t.id.equals(id))).write(
      HabitCompanion(
        nama: nama == null ? const Value.absent() : Value(nama.trim()),
        warna: warna == null ? const Value.absent() : Value(warna),
        icon: identical(icon, _unset)
            ? const Value.absent()
            : Value(icon as String?),
        updatedAt: Value(ts),
      ),
    );
  }

  /// FR-5.11: bulk reorder; [orderedIds] is the full new display order.
  Future<void> reorder(List<String> orderedIds, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(habit)..where((t) => t.id.equals(orderedIds[i]))).write(
          HabitCompanion(urutan: Value(i), updatedAt: Value(ts)),
        );
      }
    });
  }

  /// Delete policy for Habit (schema Section 2): cascade-tombstone
  /// HabitSchedule + HabitLog, then the Habit itself, in one transaction.
  /// Derived Activity rows are retained as history.
  Future<void> softDeleteHabit(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await transaction(() async {
      await (update(habitLog)
            ..where((t) => t.habitId.equals(id) & t.isDeleted.equals(false)))
          .write(HabitLogCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ));
      await (update(habitSchedule)
            ..where((t) => t.habitId.equals(id) & t.isDeleted.equals(false)))
          .write(HabitScheduleCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ));
      await (update(habit)..where((t) => t.id.equals(id))).write(
        HabitCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(ts),
          updatedAt: Value(ts),
        ),
      );
    });
  }

  // --- HabitSchedule ---

  Stream<List<HabitScheduleRow>> watchSchedules(String habitId) =>
      (select(habitSchedule)
            ..where((t) =>
                t.habitId.equals(habitId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.effectiveFrom)]))
          .watch();

  Future<List<HabitScheduleRow>> getSchedules(String habitId) =>
      (select(habitSchedule)
            ..where((t) =>
                t.habitId.equals(habitId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.effectiveFrom)]))
          .get();

  /// The HabitSchedule version active on [date] (schema 11.1: streak and
  /// quota evaluation always uses the schedule active on the date in
  /// question, not the latest one).
  Future<HabitScheduleRow?> getScheduleForDate(
      String habitId, LocalDate date) async {
    final ymd = date.toYmd();
    final rows = await (select(habitSchedule)
          ..where((t) =>
              t.habitId.equals(habitId) &
              t.isDeleted.equals(false) &
              t.effectiveFrom.isSmallerOrEqualValue(ymd) &
              (t.effectiveTo.isNull() | t.effectiveTo.isBiggerOrEqualValue(ymd))))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// FR-5.9: edit target hari / batas izin effective `effectiveFrom` (today
  /// or later). Creates a new HabitSchedule version and closes/removes
  /// neighboring versions atomically so ranges never overlap; history before
  /// `effectiveFrom` is untouched.
  Future<void> updateSchedule({
    required String habitId,
    required Set<int> targetHari,
    required int maxIzinPerMinggu,
    required LocalDate effectiveFrom,
    required LocalDate today,
    DateTime? now,
  }) async {
    if (effectiveFrom.isBefore(today)) {
      throw HabitCommandException(
          'Tanggal efektif harus hari ini atau masa depan');
    }
    if (targetHari.isEmpty) {
      throw HabitCommandException('Target hari wajib minimal satu');
    }
    if (maxIzinPerMinggu < 0) {
      throw HabitCommandException('Batas izin tidak boleh negatif');
    }
    final ts = now ?? DateTime.now().toUtc();
    await transaction(() async {
      final currentState =
          await _closeNeighbors(habitId, effectiveFrom, ts: ts);
      await into(habitSchedule).insertOnConflictUpdate(
        HabitScheduleCompanion.insert(
          id: DeterministicId.habitSchedule(habitId, effectiveFrom.toYmd()),
          createdAt: ts,
          updatedAt: ts,
          habitId: habitId,
          effectiveFrom: effectiveFrom.toYmd(),
          effectiveTo: const Value(null),
          targetHari: targetHari.toList()..sort(),
          maxIzinPerMinggu: Value(maxIzinPerMinggu),
          state: currentState,
          isDeleted: const Value(false),
          deletedAt: const Value(null),
        ),
      );
      await _recomputeStreak(habitId, today, ts: ts);
    });
  }

  /// FR-5.8: pause ("Jeda") or resume ("Lanjutkan") effective
  /// [scheduleEffectiveFrom] (default today). Creates a new HabitSchedule
  /// version carrying forward the last known target_hari/batas izin as a
  /// snapshot, then refreshes the `Habit.is_archived` cache from whichever
  /// schedule is active today.
  Future<void> setArchived({
    required String habitId,
    required bool isArchived,
    LocalDate? scheduleEffectiveFrom,
    required LocalDate today,
    DateTime? now,
  }) async {
    final effectiveFrom = scheduleEffectiveFrom ?? today;
    if (effectiveFrom.isBefore(today)) {
      throw HabitCommandException(
          'Tanggal efektif harus hari ini atau masa depan');
    }
    final ts = now ?? DateTime.now().toUtc();
    await transaction(() async {
      final snapshot = await getScheduleForDate(habitId, today) ??
          (await getSchedules(habitId)).lastOrNull;
      if (snapshot == null) {
        throw HabitCommandException('Habit belum memiliki schedule');
      }
      await _closeNeighbors(habitId, effectiveFrom, ts: ts);
      await into(habitSchedule).insertOnConflictUpdate(
        HabitScheduleCompanion.insert(
          id: DeterministicId.habitSchedule(habitId, effectiveFrom.toYmd()),
          createdAt: ts,
          updatedAt: ts,
          habitId: habitId,
          effectiveFrom: effectiveFrom.toYmd(),
          effectiveTo: const Value(null),
          targetHari: snapshot.targetHari,
          maxIzinPerMinggu: Value(snapshot.maxIzinPerMinggu),
          state: isArchived
              ? HabitScheduleState.paused
              : HabitScheduleState.active,
          isDeleted: const Value(false),
          deletedAt: const Value(null),
        ),
      );
      final todaySchedule = await getScheduleForDate(habitId, today);
      await (update(habit)..where((t) => t.id.equals(habitId))).write(
        HabitCompanion(
          isArchived: Value(
              todaySchedule != null &&
                  todaySchedule.state == HabitScheduleState.paused),
          updatedAt: Value(ts),
        ),
      );
      await _recomputeStreak(habitId, today, ts: ts);
    });
  }

  /// Closes the open-ended tail schedule and supersedes any not-yet-started
  /// *future* version, so the new version starting [effectiveFrom] never
  /// overlaps a neighbor. A schedule that already starts exactly on
  /// [effectiveFrom] shares the same deterministic id as the one about to be
  /// written (`habitSchedule(habitId, effectiveFrom)`) — it is left alone
  /// here and the caller upserts onto it in place instead of inserting a
  /// second row. Returns the state the schedule active *today* has, for
  /// callers that need to snapshot it (schema 11.1 "menyesuaikan rentang
  /// tetangga secara atomik").
  Future<HabitScheduleState> _closeNeighbors(
      String habitId, LocalDate effectiveFrom,
      {required DateTime ts}) async {
    final rows = await getSchedules(habitId);
    HabitScheduleState currentState = HabitScheduleState.active;
    for (final row in rows) {
      final rowFrom = LocalDate.parse(row.effectiveFrom);
      if (rowFrom == effectiveFrom) {
        continue;
      }
      if (rowFrom.isAfter(effectiveFrom)) {
        // Not-yet-started future version: fully superseded.
        await (update(habitSchedule)..where((t) => t.id.equals(row.id)))
            .write(HabitScheduleCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(ts),
          updatedAt: Value(ts),
        ));
        continue;
      }
      if (row.effectiveTo == null) {
        currentState = row.state;
        await (update(habitSchedule)..where((t) => t.id.equals(row.id)))
            .write(HabitScheduleCompanion(
          effectiveTo: Value(effectiveFrom.addDays(-1).toYmd()),
          updatedAt: Value(ts),
        ));
      }
    }
    return currentState;
  }

  // --- HabitLog ---

  Stream<List<HabitLogRow>> watchLogs(String habitId,
          {String? startDate, String? endDate}) =>
      (select(habitLog)
            ..where((t) {
              var expr = t.habitId.equals(habitId) & t.isDeleted.equals(false);
              if (startDate != null) {
                expr = expr & t.tanggal.isBiggerOrEqualValue(startDate);
              }
              if (endDate != null) {
                expr = expr & t.tanggal.isSmallerOrEqualValue(endDate);
              }
              return expr;
            })
            ..orderBy([(t) => OrderingTerm(expression: t.tanggal)]))
          .watch();

  Future<List<HabitLogRow>> getLogs(String habitId) => (select(habitLog)
        ..where((t) => t.habitId.equals(habitId) & t.isDeleted.equals(false)))
      .get();

  Future<HabitLogRow?> getLogForDate(String habitId, LocalDate date) =>
      (select(habitLog)
            ..where((t) =>
                t.habitId.equals(habitId) &
                t.isDeleted.equals(false) &
                t.tanggal.equals(date.toYmd())))
          .getSingleOrNull();

  /// Remaining skip quota for the Monday-Sunday week containing [date],
  /// under the schedule active on [date] (schema 11.1 "Periode izin adalah
  /// minggu kalender Senin 00.00 sampai Minggu 23:59:59"). Used by the UI to
  /// explain the limit before the user picks skip (API-SPEC 9.6).
  Future<int> remainingIzinForWeek(String habitId, LocalDate date) async {
    final schedule = await getScheduleForDate(habitId, date);
    if (schedule == null) return 0;
    final monday = date.addDays(-(date.weekday - 1));
    final sunday = monday.addDays(6);
    final logs = await (select(habitLog)
          ..where((t) =>
              t.habitId.equals(habitId) &
              t.isDeleted.equals(false) &
              t.status.equalsValue(HabitLogStatus.skip) &
              t.tanggal.isBiggerOrEqualValue(monday.toYmd()) &
              t.tanggal.isSmallerOrEqualValue(sunday.toYmd())))
        .get();
    final used = logs.length;
    final remaining = schedule.maxIzinPerMinggu - used;
    return remaining < 0 ? 0 : remaining;
  }

  /// FR-5.7/5.12/5.15: upsert the log for [habitId] on [tanggal] and keep the
  /// derived Activity consistent in the same transaction (schema 11.2,
  /// API-SPEC 9.6). [activityCategoryId] is required whenever [status] is
  /// `done` and mirrors `PomodoroDao.complete`'s pattern — the caller (cubit)
  /// supplies the seeded "Personal" category since Habit carries none of its
  /// own.
  Future<void> upsertLog({
    required String habitId,
    required LocalDate tanggal,
    required HabitLogStatus status,
    String? catatan,
    String? activityCategoryId,
    required LocalDate today,
    DateTime? now,
  }) async {
    if (tanggal.isAfter(today)) {
      throw HabitCommandException('Tidak dapat mencatat tanggal masa depan');
    }
    if (status == HabitLogStatus.done && activityCategoryId == null) {
      throw HabitCommandException(
          'activityCategoryId wajib untuk status done');
    }
    final ts = now ?? DateTime.now().toUtc();
    final habitRow = await getHabit(habitId);
    if (habitRow == null || habitRow.isDeleted) {
      throw HabitCommandException('Habit tidak ditemukan: $habitId');
    }
    final logId = DeterministicId.habitLog(habitId, tanggal.toYmd());
    final activityId = DeterministicId.derivedActivity('habit', logId);
    await transaction(() async {
      final existingLog =
          await (select(habitLog)..where((t) => t.id.equals(logId)))
              .getSingleOrNull();
      final prevStatus = existingLog?.status;

      if (status == HabitLogStatus.done) {
        final existingActivity = await (select(activity)
              ..where((t) => t.id.equals(activityId)))
            .getSingleOrNull();
        if (existingActivity == null) {
          await into(activity).insert(ActivityCompanion.insert(
            id: activityId,
            createdAt: ts,
            updatedAt: ts,
            userId: habitRow.userId,
            occurrenceDate: tanggal.toYmd(),
            judul: habitRow.nama,
            activityCategoryId: activityCategoryId!,
            isAllDay: const Value(true),
            status: ActivityStatus.selesai,
            source: ActivitySource.habit,
            sourceId: Value(logId),
            catatan: Value(catatan),
            originDeviceId: Value(habitRow.originDeviceId),
          ));
        } else if (existingActivity.isDeleted) {
          await (update(activity)..where((t) => t.id.equals(activityId)))
              .write(ActivityCompanion(
            isDeleted: const Value(false),
            deletedAt: const Value(null),
            catatan: Value(catatan),
            updatedAt: Value(ts),
          ));
        } else if (prevStatus == HabitLogStatus.done) {
          // Note-only correction on an already-done log.
          await (update(activity)..where((t) => t.id.equals(activityId)))
              .write(ActivityCompanion(
            catatan: Value(catatan),
            updatedAt: Value(ts),
          ));
        }
      } else if (prevStatus == HabitLogStatus.done) {
        await (update(activity)..where((t) => t.id.equals(activityId))).write(
          ActivityCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(ts),
            updatedAt: Value(ts),
          ),
        );
      }

      await into(habitLog).insert(
        HabitLogCompanion.insert(
          id: logId,
          createdAt: ts,
          updatedAt: ts,
          habitId: habitId,
          tanggal: tanggal.toYmd(),
          status: status,
          catatan: Value(catatan),
        ),
        onConflict: DoUpdate((_) => HabitLogCompanion(
              status: Value(status),
              catatan: Value(catatan),
              isDeleted: const Value(false),
              deletedAt: const Value(null),
              updatedAt: Value(ts),
            )),
      );

      await _recomputeStreak(habitId, today, ts: ts);
    });
  }

  // --- Streak recompute (schema 11.3; core/projections/streak.dart) ---

  Future<void> _recomputeStreak(String habitId, LocalDate today,
      {required DateTime ts}) async {
    final scheduleRows = await getSchedules(habitId);
    final logRows = await getLogs(habitId);
    final result = evaluateHabitStreak(
      schedules: scheduleRows
          .map((r) => HabitScheduleWindow(
                effectiveFrom: LocalDate.parse(r.effectiveFrom),
                effectiveTo:
                    r.effectiveTo == null ? null : LocalDate.parse(r.effectiveTo!),
                targetHari: r.targetHari.toSet(),
                maxIzinPerMinggu: r.maxIzinPerMinggu,
                state: r.state,
              ))
          .toList(),
      logs: logRows
          .map((r) => HabitLogEntry(
                tanggal: LocalDate.parse(r.tanggal),
                status: r.status,
              ))
          .toList(),
      today: today,
    );
    await (update(habit)..where((t) => t.id.equals(habitId))).write(
      HabitCompanion(
        currentStreak: Value(result.currentStreak),
        longestStreak: Value(result.longestStreak),
        updatedAt: Value(ts),
      ),
    );
  }
}

const _unset = Object();

extension _LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
