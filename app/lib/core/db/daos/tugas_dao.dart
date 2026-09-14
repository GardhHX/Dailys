import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/enums.dart';
import '../tables/m1_tables.dart';

part 'tugas_dao.g.dart';

/// Tugas + TugasChecklist access (schema 5/5.1).
@DriftAccessor(tables: [Tugas, TugasChecklist])
class TugasDao extends DatabaseAccessor<AppDatabase> with _$TugasDaoMixin {
  TugasDao(super.db);

  Future<void> insertTugas(TugasCompanion row) => into(tugas).insert(row);

  /// Active tasks (not soft-deleted), ordered by status then deadline. History
  /// (completed + 7 days, archived) is computed by the caller; the row is not
  /// mutated (schema 5).
  Stream<List<TugasRow>> watchActiveTugas(String userId) => (select(tugas)
        ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.status),
          (t) => OrderingTerm(expression: t.deadline),
        ]))
      .watch();

  /// Non-deleted, not-yet-completed tasks for [userId] — the candidate set
  /// for reminder scheduling (FR-6.4). Archive/history classification and
  /// empty-reminders filtering are the caller's job (needs a `tz.Location`
  /// this DAO doesn't have).
  Future<List<TugasRow>> getReminderCandidates(String userId) => (select(
        tugas,
      )..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.isDeleted.equals(false) &
                  t.status.equalsValue(TugasStatus.selesai).not(),
            ))
          .get();

  /// Watches one task by id (detail screen). Emits null once soft-deleted.
  Stream<TugasRow?> watchTugasById(String id) =>
      (select(tugas)..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
          .watchSingleOrNull();

  /// Sets status and keeps the `completed_at` invariant (required iff `selesai`,
  /// schema 5). Reopening from `selesai` clears `completed_at`.
  Future<void> setStatus(
    String id,
    TugasStatus status, {
    DateTime? completedAt,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    final done = status == TugasStatus.selesai;
    await (update(tugas)..where((t) => t.id.equals(id))).write(
      TugasCompanion(
        status: Value(status),
        completedAt: Value(done ? (completedAt ?? ts) : null),
        updatedAt: Value(ts),
      ),
    );
  }

  /// Edits mutable Tugas fields (judul, deskripsi, deadline, prioritas,
  /// estimasi, course, reminders). The caller supplies a [patch]; this always
  /// bumps `updated_at`. Status/completed_at go through [setStatus] and the
  /// archive flag through [setArchived] to preserve their invariants.
  Future<void> updateTugas(String id, TugasCompanion patch,
      {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(tugas)..where((t) => t.id.equals(id)))
        .write(patch.copyWith(updatedAt: Value(ts)));
  }

  /// Manual archive/unarchive (schema 5). Archiving stamps `archived_at`;
  /// unarchiving clears it. Independent of the completed-at auto-archive path.
  Future<void> setArchived(String id, bool archived, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(tugas)..where((t) => t.id.equals(id))).write(
      TugasCompanion(
        archivedAt: Value(archived ? ts : null),
        updatedAt: Value(ts),
      ),
    );
  }

  /// Delete policy for Tugas (schema Section 2): cascade-tombstone the checklist,
  /// then tombstone the task, in one transaction.
  Future<void> softDeleteTugas(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await transaction(() async {
      await (update(tugasChecklist)
            ..where((t) => t.tugasId.equals(id) & t.isDeleted.equals(false)))
          .write(TugasChecklistCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ));
      await (update(tugas)..where((t) => t.id.equals(id))).write(
        TugasCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(ts),
          updatedAt: Value(ts),
        ),
      );
    });
  }

  // --- Checklist ---

  Future<void> insertChecklistItem(TugasChecklistCompanion row) =>
      into(tugasChecklist).insert(row);

  /// Next free `urutan` for a task's checklist (max active + 1, or 0 when
  /// empty). Keeps the active `(tugas_id, urutan)` uniqueness (schema 5.1).
  Future<int> nextChecklistUrutan(String tugasId) async {
    final rows = await (select(tugasChecklist)
          ..where((t) => t.tugasId.equals(tugasId) & t.isDeleted.equals(false)))
        .get();
    if (rows.isEmpty) return 0;
    return rows.map((r) => r.urutan).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> editChecklistItem(String id, String judul,
      {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(tugasChecklist)..where((t) => t.id.equals(id))).write(
      TugasChecklistCompanion(judul: Value(judul), updatedAt: Value(ts)),
    );
  }

  Future<void> softDeleteChecklistItem(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(tugasChecklist)..where((t) => t.id.equals(id))).write(
      TugasChecklistCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }

  Stream<List<TugasChecklistRow>> watchChecklist(String tugasId) =>
      (select(tugasChecklist)
            ..where(
                (t) => t.tugasId.equals(tugasId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.urutan)]))
          .watch();

  Future<List<TugasChecklistRow>> getChecklist(String tugasId) =>
      (select(tugasChecklist)
            ..where(
                (t) => t.tugasId.equals(tugasId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.urutan)]))
          .get();

  Future<void> setChecklistDone(String id, bool isDone, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(tugasChecklist)..where((t) => t.id.equals(id))).write(
      TugasChecklistCompanion(isDone: Value(isDone), updatedAt: Value(ts)),
    );
  }
}
