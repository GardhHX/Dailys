// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_dao.dart';

// ignore_for_file: type=lint
mixin _$PomodoroDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $MataKuliahTable get mataKuliah => attachedDatabase.mataKuliah;
  $TugasTable get tugas => attachedDatabase.tugas;
  $PomodoroSessionTable get pomodoroSession => attachedDatabase.pomodoroSession;
  $ActivityCategoryTable get activityCategory =>
      attachedDatabase.activityCategory;
  $ActivityRecurrenceTable get activityRecurrence =>
      attachedDatabase.activityRecurrence;
  $ActivityTable get activity => attachedDatabase.activity;
  PomodoroDaoManager get managers => PomodoroDaoManager(this);
}

class PomodoroDaoManager {
  final _$PomodoroDaoMixin _db;
  PomodoroDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$MataKuliahTableTableManager get mataKuliah =>
      $$MataKuliahTableTableManager(_db.attachedDatabase, _db.mataKuliah);
  $$TugasTableTableManager get tugas =>
      $$TugasTableTableManager(_db.attachedDatabase, _db.tugas);
  $$PomodoroSessionTableTableManager get pomodoroSession =>
      $$PomodoroSessionTableTableManager(
          _db.attachedDatabase, _db.pomodoroSession);
  $$ActivityCategoryTableTableManager get activityCategory =>
      $$ActivityCategoryTableTableManager(
          _db.attachedDatabase, _db.activityCategory);
  $$ActivityRecurrenceTableTableManager get activityRecurrence =>
      $$ActivityRecurrenceTableTableManager(
          _db.attachedDatabase, _db.activityRecurrence);
  $$ActivityTableTableManager get activity =>
      $$ActivityTableTableManager(_db.attachedDatabase, _db.activity);
}
