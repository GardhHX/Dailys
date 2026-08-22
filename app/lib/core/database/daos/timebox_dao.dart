import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'timebox_dao.g.dart';

@DriftAccessor(tables: [TimeboxSchedule])
class TimeboxDao extends DatabaseAccessor<AppDatabase> with _$TimeboxDaoMixin {
  TimeboxDao(super.db);

  Stream<List<TimeboxScheduleData>> watchAll() {
    return (select(timeboxSchedule)..where((t) => t.isDeleted.equals(false))).watch();
  }

  Future<TimeboxScheduleData?> getById(String id) =>
      (select(timeboxSchedule)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertBlock(TimeboxScheduleCompanion entry) => into(timeboxSchedule).insert(entry);

  Future<void> updateBlock(String id, TimeboxScheduleCompanion entry) =>
      (update(timeboxSchedule)..where((t) => t.id.equals(id))).write(entry);

  /// Soft delete — jangan pernah hard delete (CLAUDE.md Section 4).
  Future<void> softDelete(String id) => (update(timeboxSchedule)..where((t) => t.id.equals(id))).write(
        TimeboxScheduleCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
}
