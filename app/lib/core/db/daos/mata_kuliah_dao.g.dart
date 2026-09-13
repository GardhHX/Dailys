// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mata_kuliah_dao.dart';

// ignore_for_file: type=lint
mixin _$MataKuliahDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $MataKuliahTable get mataKuliah => attachedDatabase.mataKuliah;
  $CourseNoteTable get courseNote => attachedDatabase.courseNote;
  $TugasTable get tugas => attachedDatabase.tugas;
  MataKuliahDaoManager get managers => MataKuliahDaoManager(this);
}

class MataKuliahDaoManager {
  final _$MataKuliahDaoMixin _db;
  MataKuliahDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$MataKuliahTableTableManager get mataKuliah =>
      $$MataKuliahTableTableManager(_db.attachedDatabase, _db.mataKuliah);
  $$CourseNoteTableTableManager get courseNote =>
      $$CourseNoteTableTableManager(_db.attachedDatabase, _db.courseNote);
  $$TugasTableTableManager get tugas =>
      $$TugasTableTableManager(_db.attachedDatabase, _db.tugas);
}
