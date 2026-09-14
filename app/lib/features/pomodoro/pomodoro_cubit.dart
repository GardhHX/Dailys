import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/ids/deterministic_id.dart';
import '../../core/time/local_date.dart';
import 'pomodoro_state.dart';

/// Drives the Pomodoro tab (design/screens/pomodoro.md; PRD Section 4.2):
/// manual start/pause/resume/complete/cancel, the consecutive-focus-session
/// streak that offers a long break (FR-2.2), and completion's single derived
/// Activity for `fokus` sessions (FR-2.12).
///
/// The timer itself is always computed from wall-clock fields
/// (`start_time`/`paused_at`/`accumulated_pause_seconds`) rather than a
/// tick counter, so it reads correctly even after the app was minimized or
/// relaunched mid-session (FR-2.14) for as long as the process stays alive;
/// see design/screens/pomodoro.md "NFR-13 tetap target native" for the
/// documented gap between that and a real OS background service.
class PomodoroCubit extends Cubit<PomodoroState> {
  PomodoroCubit({
    required AppDatabase db,
    required String userId,
    required tz.Location location,
  })  : _db = db,
        _userId = userId,
        _location = location,
        super(const PomodoroState()) {
    _init();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final AppDatabase _db;
  final String _userId;
  final tz.Location _location;
  Timer? _ticker;
  StreamSubscription<UserSettingsRow?>? _settingsSub;

  Future<void> _init() async {
    final settings = await _db.settingsDao.getUserSettings(_userId);
    final inFlight = await _db.pomodoroDao.getInFlightSession(_userId);
    final streak = await _computeFocusStreak();
    if (isClosed) return;
    emit(state.copyWith(
      settings: settings,
      current: inFlight,
      focusStreakSinceLongBreak: streak,
      now: DateTime.now().toUtc(),
      loading: false,
    ));
    _settingsSub = _db.settingsDao.watchUserSettings(_userId).listen((s) {
      if (s != null) emit(state.copyWith(settings: s));
    });
  }

  void _tick() {
    if (!isClosed) emit(state.copyWith(now: DateTime.now().toUtc()));
  }

  void retry() {
    emit(state.copyWith(loading: true, error: null));
    _init();
  }

  /// FR-2.2: walks recent sessions newest-first, counting consecutive
  /// completed `fokus` sessions; a completed long break ends the count.
  /// Short breaks, cancellations, and the in-flight session are skipped over
  /// without affecting it either way.
  Future<int> _computeFocusStreak() async {
    final recent = await _db.pomodoroDao.getRecent(_userId, limit: 50);
    var count = 0;
    for (final s in recent) {
      if (s.status != PomodoroStatus.completed) continue;
      if (s.jenis == PomodoroJenis.fokus) {
        count++;
      } else if (s.jenis == PomodoroJenis.istirahat_panjang) {
        break;
      }
    }
    return count;
  }

  int _defaultMinutes(PomodoroJenis jenis) {
    switch (jenis) {
      case PomodoroJenis.fokus:
        return state.focusMinutes;
      case PomodoroJenis.istirahat_pendek:
        return state.shortBreakMinutes;
      case PomodoroJenis.istirahat_panjang:
        return state.longBreakMinutes;
    }
  }

  /// FR-2.4/2.15: manual start; [overrideMinutes] is a one-session preset
  /// override (FR-2.15/2.16), never a change to the global setting.
  Future<void> start({
    required PomodoroJenis jenis,
    String? tugasId,
    String? habitId,
    int? overrideMinutes,
  }) async {
    final minutes = overrideMinutes ?? _defaultMinutes(jenis);
    final id = await _db.pomodoroDao.start(
      userId: _userId,
      durasiMenit: minutes,
      jenis: jenis,
      tugasId: tugasId,
      habitId: habitId,
    );
    final row = await _db.pomodoroDao.getById(id);
    emit(state.copyWith(current: row, now: DateTime.now().toUtc()));
  }

  Future<void> pause() async {
    final id = state.current?.id;
    if (id == null) return;
    await _db.pomodoroDao.pause(id);
    await _refreshCurrent();
  }

  Future<void> resume() async {
    final id = state.current?.id;
    if (id == null) return;
    await _db.pomodoroDao.resume(id);
    await _refreshCurrent();
  }

  /// FR-2.10/2.12: complete; only a `fokus` session gets a derived Activity
  /// (schema 9 has no `judul`/category of its own, so those are supplied
  /// here — [judul] falls back to a generic label, and the category defaults
  /// to the seeded "Personal" ActivityCategory since PomodoroSession carries
  /// no category link at all).
  Future<void> complete({String? judul}) async {
    final current = state.current;
    if (current == null) return;
    final isFocus = current.jenis == PomodoroJenis.fokus;
    await _db.pomodoroDao.complete(
      current.id,
      activityJudul: isFocus ? (judul ?? 'Pomodoro') : null,
      activityCategoryId:
          isFocus ? DeterministicId.seedActivityCategory(_userId, 'personal') : null,
      occurrenceDate:
          isFocus ? LocalDate.fromInstant(current.startTime, _location).toYmd() : null,
    );
    var streak = state.focusStreakSinceLongBreak;
    if (isFocus) {
      streak += 1;
    } else if (current.jenis == PomodoroJenis.istirahat_panjang) {
      streak = 0;
    }
    emit(state.copyWith(
        clearCurrent: true, focusStreakSinceLongBreak: streak, now: DateTime.now().toUtc()));
  }

  /// FR-2.8/2.9: cancel (focus, needs prior UI confirmation) or skip (break,
  /// no confirmation needed) — same DAO command either way; never produces an
  /// Activity and never touches the streak.
  Future<void> cancel() async {
    final id = state.current?.id;
    if (id == null) return;
    await _db.pomodoroDao.cancel(id);
    emit(state.copyWith(clearCurrent: true, now: DateTime.now().toUtc()));
  }

  Future<void> _refreshCurrent() async {
    final id = state.current?.id;
    if (id == null) return;
    final row = await _db.pomodoroDao.getById(id);
    emit(state.copyWith(current: row, now: DateTime.now().toUtc()));
  }

  Stream<List<PomodoroSessionRow>> watchRecent({int limit = 20}) =>
      _db.pomodoroDao.watchRecent(_userId, limit: limit);

  @override
  Future<void> close() {
    _ticker?.cancel();
    _settingsSub?.cancel();
    return super.close();
  }
}
