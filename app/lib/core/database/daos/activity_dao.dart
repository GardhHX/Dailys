import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'activity_dao.g.dart';

@DriftAccessor(tables: [Activity])
class ActivityDao extends DatabaseAccessor<AppDatabase> with _$ActivityDaoMixin {
  ActivityDao(super.db);

  /// Semua activity aktif — dipakai [ActivityRepository] untuk menghitung
  /// kemunculan (occurrence) recurring activity di tanggal manapun, karena
  /// itu tidak bisa dijawab lewat query 1 tanggal saja.
  Stream<List<ActivityData>> watchAll() {
    return (select(activity)..where((a) => a.isDeleted.equals(false))).watch();
  }

  Future<ActivityData?> getById(String id) =>
      (select(activity)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<void> insertActivity(ActivityCompanion entry) => into(activity).insert(entry);

  Future<void> updateActivity(String id, ActivityCompanion entry) =>
      (update(activity)..where((a) => a.id.equals(id))).write(entry);

  /// Soft delete — jangan pernah hard delete (CLAUDE.md Section 4).
  Future<void> softDelete(String id) => (update(activity)..where((a) => a.id.equals(id))).write(
        ActivityCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// FR-1.11 — tandai semua activity hari itu selesai.
  Future<int> bulkComplete(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (update(activity)
          ..where((a) =>
              a.isDeleted.equals(false) &
              a.startTime.isBiggerOrEqualValue(start) &
              a.startTime.isSmallerThanValue(end) &
              a.status.equals('selesai').not()))
        .write(ActivityCompanion(
      status: const Value('selesai'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// FR-1.11 — pindahkan semua activity yang belum selesai ke hari lain
  /// (mempertahankan jam, hanya tanggalnya yang berubah).
  Future<void> bulkReschedule(DateTime fromDate, DateTime toDate) async {
    final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final end = start.add(const Duration(days: 1));

    final pending = await (select(activity)
          ..where((a) =>
              a.isDeleted.equals(false) &
              a.startTime.isBiggerOrEqualValue(start) &
              a.startTime.isSmallerThanValue(end) &
              a.status.equals('selesai').not()))
        .get();

    for (final a in pending) {
      final delta = Duration(
        days: DateTime(toDate.year, toDate.month, toDate.day)
            .difference(DateTime(fromDate.year, fromDate.month, fromDate.day))
            .inDays,
      );
      await updateActivity(
        a.id,
        ActivityCompanion(
          startTime: Value(a.startTime?.add(delta)),
          endTime: Value(a.endTime?.add(delta)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
}
