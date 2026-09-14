// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timebox_dao.dart';

// ignore_for_file: type=lint
mixin _$TimeboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $MataKuliahTable get mataKuliah => attachedDatabase.mataKuliah;
  $TugasTable get tugas => attachedDatabase.tugas;
  $ActivityCategoryTable get activityCategory =>
      attachedDatabase.activityCategory;
  $TimeboxScheduleTable get timeboxSchedule => attachedDatabase.timeboxSchedule;
  $ActivityRecurrenceTable get activityRecurrence =>
      attachedDatabase.activityRecurrence;
  $ActivityTable get activity => attachedDatabase.activity;
  $TimeboxExecutionTable get timeboxExecution =>
      attachedDatabase.timeboxExecution;
  TimeboxDaoManager get managers => TimeboxDaoManager(this);
}

class TimeboxDaoManager {
  final _$TimeboxDaoMixin _db;
  TimeboxDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$MataKuliahTableTableManager get mataKuliah =>
      $$MataKuliahTableTableManager(_db.attachedDatabase, _db.mataKuliah);
  $$TugasTableTableManager get tugas =>
      $$TugasTableTableManager(_db.attachedDatabase, _db.tugas);
  $$ActivityCategoryTableTableManager get activityCategory =>
      $$ActivityCategoryTableTableManager(
          _db.attachedDatabase, _db.activityCategory);
  $$TimeboxScheduleTableTableManager get timeboxSchedule =>
      $$TimeboxScheduleTableTableManager(
          _db.attachedDatabase, _db.timeboxSchedule);
  $$ActivityRecurrenceTableTableManager get activityRecurrence =>
      $$ActivityRecurrenceTableTableManager(
          _db.attachedDatabase, _db.activityRecurrence);
  $$ActivityTableTableManager get activity =>
      $$ActivityTableTableManager(_db.attachedDatabase, _db.activity);
  $$TimeboxExecutionTableTableManager get timeboxExecution =>
      $$TimeboxExecutionTableTableManager(
          _db.attachedDatabase, _db.timeboxExecution);
}
