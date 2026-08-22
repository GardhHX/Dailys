// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tugas_dao.dart';

// ignore_for_file: type=lint
mixin _$TugasDaoMixin on DatabaseAccessor<AppDatabase> {
  $MataKuliahTable get mataKuliah => attachedDatabase.mataKuliah;
  $TugasTable get tugas => attachedDatabase.tugas;
  $TugasChecklistTable get tugasChecklist => attachedDatabase.tugasChecklist;
  TugasDaoManager get managers => TugasDaoManager(this);
}

class TugasDaoManager {
  final _$TugasDaoMixin _db;
  TugasDaoManager(this._db);
  $$MataKuliahTableTableManager get mataKuliah =>
      $$MataKuliahTableTableManager(_db.attachedDatabase, _db.mataKuliah);
  $$TugasTableTableManager get tugas =>
      $$TugasTableTableManager(_db.attachedDatabase, _db.tugas);
  $$TugasChecklistTableTableManager get tugasChecklist =>
      $$TugasChecklistTableTableManager(
        _db.attachedDatabase,
        _db.tugasChecklist,
      );
}
