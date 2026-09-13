import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/ids/deterministic_id.dart';

/// State for the Tugas detail route: the task (null once deleted), its active
/// checklist, and the owning course when set.
class TugasDetailState {
  const TugasDetailState({
    this.tugas,
    this.checklist = const [],
    this.course,
    this.loading = true,
  });

  final TugasRow? tugas;
  final List<TugasChecklistRow> checklist;
  final MataKuliahRow? course;
  final bool loading;

  bool get allChecklistDone =>
      checklist.isNotEmpty && checklist.every((c) => c.isDone);

  TugasDetailState copyWith({
    TugasRow? tugas,
    bool clearTugas = false,
    List<TugasChecklistRow>? checklist,
    MataKuliahRow? course,
    bool clearCourse = false,
    bool? loading,
  }) =>
      TugasDetailState(
        tugas: clearTugas ? null : (tugas ?? this.tugas),
        checklist: checklist ?? this.checklist,
        course: clearCourse ? null : (course ?? this.course),
        loading: loading ?? this.loading,
      );
}

class TugasDetailCubit extends Cubit<TugasDetailState> {
  TugasDetailCubit({required AppDatabase db, required String tugasId})
      : _db = db,
        _tugasId = tugasId,
        super(const TugasDetailState()) {
    _tugasSub = _db.tugasDao.watchTugasById(_tugasId).listen((row) async {
      _tugas = row;
      final courseId = row?.mataKuliahId;
      _course =
          courseId == null ? null : await _db.mataKuliahDao.getById(courseId);
      _taskReady = true;
      _emit();
    });
    _checklistSub = _db.tugasDao.watchChecklist(_tugasId).listen((rows) {
      _checklist = rows;
      _checklistReady = true;
      _emit();
    });
  }

  final AppDatabase _db;
  final String _tugasId;
  bool _taskReady = false;
  bool _checklistReady = false;

  StreamSubscription<TugasRow?>? _tugasSub;
  StreamSubscription<List<TugasChecklistRow>>? _checklistSub;
  TugasRow? _tugas;
  List<TugasChecklistRow> _checklist = const [];
  MataKuliahRow? _course;

  void _emit() => emit(TugasDetailState(
        tugas: _tugas,
        checklist: _checklist,
        course: _course,
        loading: !(_taskReady && _checklistReady),
      ));

  Future<void> setStatus(TugasStatus status) =>
      _db.tugasDao.setStatus(_tugasId, status);

  Future<void> setArchived(bool archived) =>
      _db.tugasDao.setArchived(_tugasId, archived);

  Future<void> addChecklistItem(String judul) async {
    final ts = DateTime.now().toUtc();
    final urutan = await _db.tugasDao.nextChecklistUrutan(_tugasId);
    await _db.tugasDao.insertChecklistItem(TugasChecklistCompanion.insert(
      id: DeterministicId.v4(),
      createdAt: ts,
      updatedAt: ts,
      tugasId: _tugasId,
      judul: judul,
      urutan: urutan,
    ));
  }

  Future<void> setChecklistDone(String id, bool done) =>
      _db.tugasDao.setChecklistDone(id, done);

  Future<void> editChecklistItem(String id, String judul) =>
      _db.tugasDao.editChecklistItem(id, judul);

  Future<void> deleteChecklistItem(String id) =>
      _db.tugasDao.softDeleteChecklistItem(id);

  Future<void> deleteTugas() => _db.tugasDao.softDeleteTugas(_tugasId);

  @override
  Future<void> close() {
    _tugasSub?.cancel();
    _checklistSub?.cancel();
    return super.close();
  }
}
