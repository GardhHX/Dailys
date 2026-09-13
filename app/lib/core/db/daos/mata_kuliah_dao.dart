import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/m1_tables.dart';

part 'mata_kuliah_dao.g.dart';

/// MataKuliah + CourseNote access (schema 4/4.1), including the delete policy
/// that cascade-tombstones notes and detaches tasks (schema Section 2).
@DriftAccessor(tables: [MataKuliah, CourseNote, Tugas])
class MataKuliahDao extends DatabaseAccessor<AppDatabase>
    with _$MataKuliahDaoMixin {
  MataKuliahDao(super.db);

  Future<void> insertMataKuliah(MataKuliahCompanion row) =>
      into(mataKuliah).insert(row);

  Stream<List<MataKuliahRow>> watchActiveMataKuliah(String userId) =>
      (select(mataKuliah)
            ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.nama)]))
          .watch();

  /// Delete policy for MataKuliah (schema Section 2): in one transaction,
  /// cascade-tombstone every CourseNote, detach Tugas (`mata_kuliah_id = null`,
  /// history kept), then tombstone the course itself.
  Future<void> softDeleteMataKuliah(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await transaction(() async {
      await (update(courseNote)
            ..where((t) => t.mataKuliahId.equals(id) & t.isDeleted.equals(false)))
          .write(CourseNoteCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ));

      await (update(tugas)
            ..where((t) => t.mataKuliahId.equals(id) & t.isDeleted.equals(false)))
          .write(TugasCompanion(
        mataKuliahId: const Value(null),
        updatedAt: Value(ts),
      ));

      await (update(mataKuliah)..where((t) => t.id.equals(id))).write(
        MataKuliahCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(ts),
          updatedAt: Value(ts),
        ),
      );
    });
  }

  // --- CourseNote ---

  Future<void> insertCourseNote(CourseNoteCompanion row) =>
      into(courseNote).insert(row);

  /// Active notes for a course, newest logical date first, filtered by [date]
  /// (`YYYY-MM-DD`) when given (schema 4.1 index / API `?date=`).
  Stream<List<CourseNoteRow>> watchCourseNotes(String mataKuliahId, {String? date}) {
    final q = select(courseNote)
      ..where((t) => t.mataKuliahId.equals(mataKuliahId) & t.isDeleted.equals(false));
    if (date != null) q.where((t) => t.tanggal.equals(date));
    q.orderBy([
      (t) => OrderingTerm(expression: t.tanggal, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    return q.watch();
  }

  Future<void> softDeleteCourseNote(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(courseNote)..where((t) => t.id.equals(id))).write(
      CourseNoteCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }
}
