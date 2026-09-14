// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $HabitTable get habit => attachedDatabase.habit;
  $HabitScheduleTable get habitSchedule => attachedDatabase.habitSchedule;
  $HabitLogTable get habitLog => attachedDatabase.habitLog;
  $ActivityCategoryTable get activityCategory =>
      attachedDatabase.activityCategory;
  $ActivityRecurrenceTable get activityRecurrence =>
      attachedDatabase.activityRecurrence;
  $ActivityTable get activity => attachedDatabase.activity;
  HabitDaoManager get managers => HabitDaoManager(this);
}

class HabitDaoManager {
  final _$HabitDaoMixin _db;
  HabitDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$HabitTableTableManager get habit =>
      $$HabitTableTableManager(_db.attachedDatabase, _db.habit);
  $$HabitScheduleTableTableManager get habitSchedule =>
      $$HabitScheduleTableTableManager(_db.attachedDatabase, _db.habitSchedule);
  $$HabitLogTableTableManager get habitLog =>
      $$HabitLogTableTableManager(_db.attachedDatabase, _db.habitLog);
  $$ActivityCategoryTableTableManager get activityCategory =>
      $$ActivityCategoryTableTableManager(
          _db.attachedDatabase, _db.activityCategory);
  $$ActivityRecurrenceTableTableManager get activityRecurrence =>
      $$ActivityRecurrenceTableTableManager(
          _db.attachedDatabase, _db.activityRecurrence);
  $$ActivityTableTableManager get activity =>
      $$ActivityTableTableManager(_db.attachedDatabase, _db.activity);
}
