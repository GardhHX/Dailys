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
  Stream<List<TugasRow>> watchActiveTugas(String userId) =>
      (select(tugas)
            ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
            ..orderBy([
              (t) => OrderingTerm(expression: t.status),
              (t) => OrderingTerm(expression: t.deadline),
            ]))
          .watch();

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

  Stream<List<TugasChecklistRow>> watchChecklist(String tugasId) =>
      (select(tugasChecklist)
            ..where((t) => t.tugasId.equals(tugasId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.urutan)]))
          .watch();

  Future<void> setChecklistDone(String id, bool isDone, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(tugasChecklist)..where((t) => t.id.equals(id))).write(
      TugasChecklistCompanion(isDone: Value(isDone), updatedAt: Value(ts)),
    );
  }
}
