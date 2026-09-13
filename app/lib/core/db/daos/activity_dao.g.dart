// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dao.dart';

// ignore_for_file: type=lint
mixin _$ActivityDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $ActivityCategoryTable get activityCategory =>
      attachedDatabase.activityCategory;
  $ActivityRecurrenceTable get activityRecurrence =>
      attachedDatabase.activityRecurrence;
  $ActivityTable get activity => attachedDatabase.activity;
  ActivityDaoManager get managers => ActivityDaoManager(this);
}

class ActivityDaoManager {
  final _$ActivityDaoMixin _db;
  ActivityDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$ActivityCategoryTableTableManager get activityCategory =>
      $$ActivityCategoryTableTableManager(
          _db.attachedDatabase, _db.activityCategory);
  $$ActivityRecurrenceTableTableManager get activityRecurrence =>
      $$ActivityRecurrenceTableTableManager(
          _db.attachedDatabase, _db.activityRecurrence);
  $$ActivityTableTableManager get activity =>
      $$ActivityTableTableManager(_db.attachedDatabase, _db.activity);
}
