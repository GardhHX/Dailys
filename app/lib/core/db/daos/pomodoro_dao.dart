import 'package:drift/drift.dart';

import '../../ids/deterministic_id.dart';
import '../database.dart';
import '../tables/enums.dart';
import '../tables/m1_tables.dart';
import '../tables/m3_tables.dart';

part 'pomodoro_dao.g.dart';

/// Thrown by PomodoroSession commands whose preconditions the schema mandates
/// (schema 9): pause/resume/complete/cancel only from their valid source
/// status.
class PomodoroCommandException implements Exception {
  PomodoroCommandException(this.message);
  final String message;
  @override
  String toString() => 'PomodoroCommandException: $message';
}

/// PomodoroSession access (schema 9). Also touches `Activity` directly (like
/// `TimeboxDao`) so completing a `fokus` session creates its single Activity
/// in the same transaction as the status update (FR-2.12).
@DriftAccessor(tables: [PomodoroSession, Activity])
class PomodoroDao extends DatabaseAccessor<AppDatabase> with _$PomodoroDaoMixin {
  PomodoroDao(super.db);

  Future<PomodoroSessionRow?> getById(String id) =>
      (select(pomodoroSession)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// The in-flight session (running or paused) for [userId], if any — used to
  /// resume the timer UI after an app restart without ever silently turning it
  /// `cancelled` (schema 9 / FR-2.14).
  Future<PomodoroSessionRow?> getInFlightSession(String userId) => (select(
        pomodoroSession,
      )..where(
          (t) =>
              t.userId.equals(userId) &
              t.isDeleted.equals(false) &
              (t.status.equalsValue(PomodoroStatus.running) |
                  t.status.equalsValue(PomodoroStatus.paused)),
        ))
      .getSingleOrNull();

  /// Completed `fokus` sessions for [userId] from [from] (Instant, inclusive)
  /// onward — the raw candidate set for daily/weekly/monthly statistics
  /// (schema 9 / FR-2.10-2.11). Local-date grouping needs a `tz.Location` this
  /// DAO doesn't have, so callers group the result themselves (mirrors
  /// `TugasDao.getReminderCandidates`).
  Future<List<PomodoroSessionRow>> getCompletedFocusSessions(
    String userId, {
    DateTime? from,
  }) {
    final query = select(pomodoroSession)
      ..where((t) =>
          t.userId.equals(userId) &
          t.isDeleted.equals(false) &
          t.jenis.equalsValue(PomodoroJenis.fokus) &
          t.status.equalsValue(PomodoroStatus.completed));
    if (from != null) {
      query.where((t) => t.startTime.isBiggerOrEqualValue(from));
    }
    return query.get();
  }

  Stream<List<PomodoroSessionRow>> watchRecent(String userId, {int limit = 20}) =>
      (select(pomodoroSession)
            ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
            ..limit(limit))
          .watch();

  /// Same ordering as [watchRecent] as a one-shot read — used to derive the
  /// FR-2.2 consecutive-focus-session streak on init/after each completion.
  Future<List<PomodoroSessionRow>> getRecent(String userId, {int limit = 20}) =>
      (select(pomodoroSession)
            ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
            ..limit(limit))
          .get();

  /// FR-2.4: manual start, `fokus`/break both begin `running`.
  Future<String> start({
    required String userId,
    required int durasiMenit,
    required PomodoroJenis jenis,
    String? tugasId,
    String? habitId,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    final id = DeterministicId.v4();
    await into(pomodoroSession).insert(PomodoroSessionCompanion.insert(
      id: id,
      createdAt: ts,
      updatedAt: ts,
      userId: userId,
      tugasId: Value(tugasId),
      habitId: Value(habitId),
      startTime: ts,
      durasiMenit: durasiMenit,
      jenis: jenis,
      status: PomodoroStatus.running,
    ));
    return id;
  }

  Future<PomodoroSessionRow> _requireStatus(
      String id, Set<PomodoroStatus> allowed) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) {
      throw PomodoroCommandException('Sesi tidak ditemukan: $id');
    }
    if (!allowed.contains(row.status)) {
      throw PomodoroCommandException(
          'Command tidak berlaku dari status ${row.status.name}');
    }
    return row;
  }

  /// FR-2.7: pause stores `paused_at` and stops actual-time accrual.
  Future<void> pause(String id, {DateTime? now}) async {
    final row = await _requireStatus(id, {PomodoroStatus.running});
    final ts = now ?? DateTime.now().toUtc();
    if (ts.isBefore(row.startTime)) {
      throw PomodoroCommandException('Timestamp command sebelum start_time.');
    }
    await (update(pomodoroSession)..where((t) => t.id.equals(id))).write(
      PomodoroSessionCompanion(
        status: const Value(PomodoroStatus.paused),
        pausedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }

  /// FR-2.7: resume adds the pause length to the accumulator and clears
  /// `paused_at`.
  Future<void> resume(String id, {DateTime? now}) async {
    final row = await _requireStatus(id, {PomodoroStatus.paused});
    final ts = now ?? DateTime.now().toUtc();
    final pausedAt = row.pausedAt!;
    if (ts.isBefore(pausedAt)) {
      throw PomodoroCommandException('Timestamp command sebelum paused_at.');
    }
    final addedPause = ts.difference(pausedAt).inSeconds;
    await (update(pomodoroSession)..where((t) => t.id.equals(id))).write(
      PomodoroSessionCompanion(
        status: const Value(PomodoroStatus.running),
        pausedAt: const Value(null),
        accumulatedPauseSeconds: Value(row.accumulatedPauseSeconds + addedPause),
        updatedAt: Value(ts),
      ),
    );
  }

  /// FR-2.10/2.12: completes the session, folding any still-open pause into
  /// the accumulator first, computing `actual_seconds`, and — only for a
  /// `fokus` session — creating exactly one derived Activity in the same
  /// transaction. Break sessions never produce an Activity (design/screens/
  /// pomodoro.md). [activityJudul] and [activityCategoryId] are only used
  /// (and required) when the session is `fokus`; PomodoroSession carries no
  /// category of its own (schema 9), so the caller supplies one — the
  /// PomodoroCubit defaults to the seeded "Personal" ActivityCategory.
  Future<String?> complete(
    String id, {
    DateTime? now,
    String? activityJudul,
    String? activityCategoryId,
    String? occurrenceDate,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    return transaction(() async {
      final row = await _requireStatus(id, {PomodoroStatus.running, PomodoroStatus.paused});
      if (ts.isBefore(row.startTime)) {
        throw PomodoroCommandException('Timestamp command sebelum start_time.');
      }
      var accumulatedPause = row.accumulatedPauseSeconds;
      if (row.status == PomodoroStatus.paused) {
        accumulatedPause += ts.difference(row.pausedAt!).inSeconds;
      }
      final actualSeconds = _actualSeconds(row.startTime, ts, accumulatedPause);

      String? activityId;
      if (row.jenis == PomodoroJenis.fokus) {
        if (activityCategoryId == null || occurrenceDate == null) {
          throw PomodoroCommandException(
              'activityCategoryId dan occurrenceDate wajib untuk sesi fokus.');
        }
        activityId = DeterministicId.derivedActivity('pomodoro', row.id);
        await into(activity).insert(
          ActivityCompanion.insert(
            id: activityId,
            createdAt: ts,
            updatedAt: ts,
            userId: row.userId,
            occurrenceDate: occurrenceDate,
            judul: activityJudul ?? 'Pomodoro',
            activityCategoryId: activityCategoryId,
            startTime: Value(row.startTime),
            endTime: Value(ts),
            isAllDay: const Value(false),
            status: ActivityStatus.selesai,
            source: ActivitySource.pomodoro,
            sourceId: Value(row.id),
            originDeviceId: Value(row.originDeviceId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      await (update(pomodoroSession)..where((t) => t.id.equals(id))).write(
        PomodoroSessionCompanion(
          status: const Value(PomodoroStatus.completed),
          endTime: Value(ts),
          pausedAt: const Value(null),
          accumulatedPauseSeconds: Value(accumulatedPause),
          actualSeconds: Value(actualSeconds),
          updatedAt: Value(ts),
        ),
      );
      return activityId;
    });
  }

  /// FR-2.8/2.9: cancels a focus or skips a break session. Never produces an
  /// Activity and requires the caller to have already confirmed (for a focus
  /// cancel) per FR-2.9 — that confirmation is a UI concern, not this DAO's.
  Future<void> cancel(String id, {DateTime? now}) async {
    final row = await _requireStatus(id, {PomodoroStatus.running, PomodoroStatus.paused});
    final ts = now ?? DateTime.now().toUtc();
    if (ts.isBefore(row.startTime)) {
      throw PomodoroCommandException('Timestamp command sebelum start_time.');
    }
    var accumulatedPause = row.accumulatedPauseSeconds;
    if (row.status == PomodoroStatus.paused) {
      accumulatedPause += ts.difference(row.pausedAt!).inSeconds;
    }
    await (update(pomodoroSession)..where((t) => t.id.equals(id))).write(
      PomodoroSessionCompanion(
        status: const Value(PomodoroStatus.cancelled),
        endTime: Value(ts),
        pausedAt: const Value(null),
        accumulatedPauseSeconds: Value(accumulatedPause),
        updatedAt: Value(ts),
      ),
    );
  }

  int _actualSeconds(DateTime start, DateTime end, int accumulatedPauseSeconds) {
    final raw = end.difference(start).inSeconds - accumulatedPauseSeconds;
    return raw < 0 ? 0 : raw;
  }
}
