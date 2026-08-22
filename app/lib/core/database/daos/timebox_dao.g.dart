// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timebox_dao.dart';

// ignore_for_file: type=lint
mixin _$TimeboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $TimeboxScheduleTable get timeboxSchedule => attachedDatabase.timeboxSchedule;
  TimeboxDaoManager get managers => TimeboxDaoManager(this);
}

class TimeboxDaoManager {
  final _$TimeboxDaoMixin _db;
  TimeboxDaoManager(this._db);
  $$TimeboxScheduleTableTableManager get timeboxSchedule =>
      $$TimeboxScheduleTableTableManager(
        _db.attachedDatabase,
        _db.timeboxSchedule,
      );
}
