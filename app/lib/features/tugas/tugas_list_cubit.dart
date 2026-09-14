import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/ids/deterministic_id.dart';
import '../../core/reminders/task_reminder.dart';
import '../../core/time/local_date.dart';
import 'domain/tugas_history.dart';
import 'tugas_list_state.dart';

/// Drives the Tugas tab (design/screens/tugas.md; M1-PLAN `features/tugas`):
/// active list with filter/sort, week-navigable history, and Tugas CRUD +
/// lifecycle/archive. Checklist edits live in the detail cubit.
class TugasListCubit extends Cubit<TugasListState> {
  TugasListCubit({
    required AppDatabase db,
    required String userId,
    required tz.Location location,
    DateTime Function()? now,
  })  : _db = db,
        _userId = userId,
        _location = location,
        _now = now ?? (() => DateTime.now().toUtc()),
        super(_initial(location)) {
    _watch();
    // Re-derives `today`/`now` even absent a DB write, so a task that crosses
    // the day boundary (active/history split, schema 5) or an overdue
    // deadline doesn't sit stale while this screen stays open — mirrors
    // ActivityHomeCubit's clock tick.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => refreshClock());
  }

  /// Re-derives `today`/`now` immediately instead of waiting for the next
  /// periodic tick. The clock timer calls this too; exposed (not private) so
  /// tests can call it directly instead of waiting on a real [Timer].
  void refreshClock() => _emit();

  final tz.Location _location;
  final DateTime Function() _now;
  Timer? _clock;
  bool _tasksReady = false;
  bool _coursesReady = false;
  void _watch() {
    _tugasSub = _db.tugasDao.watchActiveTugas(_userId).listen((rows) {
      _tugas = rows;
      _tasksReady = true;
      _emit();
    }, onError: (_) => emit(state.copyWith(loading: false, failed: true)));
    _coursesSub =
        _db.mataKuliahDao.watchActiveMataKuliah(_userId).listen((rows) {
      _courses = rows;
      _coursesReady = true;
      _emit();
    }, onError: (_) => emit(state.copyWith(loading: false, failed: true)));
  }

  void retry() {
    _tugasSub?.cancel();
    _coursesSub?.cancel();
    _tasksReady = false;
    _coursesReady = false;
    emit(state.copyWith(loading: true, failed: false));
    _watch();
  }

  final AppDatabase _db;
  final String _userId;

  Stream<List<TugasChecklistRow>> watchChecklist(String tugasId) =>
      _db.tugasDao.watchChecklist(tugasId);

  StreamSubscription<List<TugasRow>>? _tugasSub;
  StreamSubscription<List<MataKuliahRow>>? _coursesSub;
  List<TugasRow> _tugas = const [];
  List<MataKuliahRow> _courses = const [];

  static TugasListState _initial(tz.Location location) {
    final today = LocalDate.fromInstant(DateTime.now().toUtc(), location);
    return TugasListState(
      location: location,
      today: today,
      now: DateTime.now().toUtc(),
      historyWeek: WeekRange.of(today),
    );
  }

  void _emit() {
    if (isClosed) return;
    final nowInstant = _now();
    emit(state.copyWith(
      tugas: _tugas,
      courses: _courses,
      today: LocalDate.fromInstant(nowInstant, _location),
      now: nowInstant,
      loading: !state.failed && !(_tasksReady && _coursesReady),
    ));
  }

  // --- Filters / sort / history navigation ---

  void setStatusFilter(TugasStatus? status) => emit(status == null
      ? state.copyWith(clearStatusFilter: true)
      : state.copyWith(statusFilter: status));

  void setPriorityFilter(TugasPrioritas? p) => emit(p == null
      ? state.copyWith(clearPriorityFilter: true)
      : state.copyWith(priorityFilter: p));

  void setCourseFilter(String? id) => emit(id == null
      ? state.copyWith(clearCourseFilter: true)
      : state.copyWith(courseFilter: id));

  void clearFilters() => emit(state.copyWith(
        clearStatusFilter: true,
        clearPriorityFilter: true,
        clearCourseFilter: true,
      ));

  void setSort(TugasSort sort) => emit(state.copyWith(sort: sort));

  void historyPreviousWeek() =>
      emit(state.copyWith(historyWeek: state.historyWeek.previous));

  void historyNextWeek() =>
      emit(state.copyWith(historyWeek: state.historyWeek.next));

  void historyThisWeek() =>
      emit(state.copyWith(historyWeek: WeekRange.of(state.today)));

  // --- CRUD ---

  /// Creates a task with the default reminder set (schema 5) unless [reminders]
  /// is supplied. New tasks start `belum`.
  Future<void> createTugas({
    required String judul,
    required DateTime deadline,
    required TugasPrioritas prioritas,
    String? deskripsi,
    String? mataKuliahId,
    int? estimasiMenit,
    List<TaskReminder>? reminders,
  }) async {
    final ts = DateTime.now().toUtc();
    await _db.tugasDao.insertTugas(TugasCompanion.insert(
      id: DeterministicId.v4(),
      createdAt: ts,
      updatedAt: ts,
      userId: _userId,
      mataKuliahId: Value(mataKuliahId),
      judul: judul,
      deskripsi: Value(deskripsi),
      deadline: deadline,
      prioritas: prioritas,
      estimasiMenit: Value(estimasiMenit),
      status: TugasStatus.belum,
      reminders: TaskReminder.toJsonList(
        TaskReminder.dedupe(reminders ?? TaskReminder.defaults()),
      ),
    ));
  }

  Future<void> editTugas({
    required String id,
    required String judul,
    required DateTime deadline,
    required TugasPrioritas prioritas,
    String? deskripsi,
    String? mataKuliahId,
    int? estimasiMenit,
    List<TaskReminder>? reminders,
  }) async {
    await _db.tugasDao.updateTugas(
      id,
      TugasCompanion(
        judul: Value(judul),
        deskripsi: Value(deskripsi),
        deadline: Value(deadline),
        prioritas: Value(prioritas),
        mataKuliahId: Value(mataKuliahId),
        estimasiMenit: Value(estimasiMenit),
        reminders: reminders == null
            ? const Value.absent()
            : Value(TaskReminder.toJsonList(TaskReminder.dedupe(reminders))),
      ),
    );
  }

  Future<void> setStatus(String id, TugasStatus status) =>
      _db.tugasDao.setStatus(id, status);

  Future<void> setArchived(String id, bool archived) =>
      _db.tugasDao.setArchived(id, archived);

  Future<void> deleteTugas(String id) => _db.tugasDao.softDeleteTugas(id);

  @override
  Future<void> close() {
    _clock?.cancel();
    _tugasSub?.cancel();
    _coursesSub?.cancel();
    return super.close();
  }
}
