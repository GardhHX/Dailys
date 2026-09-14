import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';

class PomodoroState {
  const PomodoroState({
    this.current,
    this.now,
    this.settings,
    this.focusStreakSinceLongBreak = 0,
    this.recentSessions = const [],
    this.loading = true,
    this.error,
    this.busy = false,
  });

  /// The in-flight (running/paused) session, or the just-finished one until
  /// the UI dismisses it. Null when idle.
  final PomodoroSessionRow? current;

  /// Re-derived on a 1s tick so the circular timer stays live.
  final DateTime? now;
  final UserSettingsRow? settings;

  /// Consecutive completed `fokus` sessions since the last completed long
  /// break (FR-2.2); short breaks and cancellations don't reset it.
  final int focusStreakSinceLongBreak;
  final List<PomodoroSessionRow> recentSessions;
  final bool loading;
  final String? error;
  final bool busy;

  int get focusMinutes => settings?.pomodoroFocusMinutes ?? 25;
  int get shortBreakMinutes => settings?.pomodoroShortBreakMinutes ?? 5;
  int get longBreakMinutes => settings?.pomodoroLongBreakMinutes ?? 15;
  int get longBreakInterval => settings?.pomodoroLongBreakInterval ?? 4;

  /// FR-2.2: offer a long break once the streak hits the configured
  /// interval. Only meaningful once idle (no [current] session).
  bool get shouldOfferLongBreak =>
      current == null &&
      focusStreakSinceLongBreak > 0 &&
      focusStreakSinceLongBreak % longBreakInterval == 0;

  bool get isPaused => current?.status == PomodoroStatus.paused;
  bool get isRunning => current?.status == PomodoroStatus.running;

  /// Actual elapsed seconds excluding pauses, live if still running/paused.
  /// [current] is only ever running/paused (the cubit clears it right after
  /// complete/cancel), so those are the only two shapes handled here.
  int get elapsedSeconds {
    final c = current;
    if (c == null) return 0;
    // Paused: accrual stopped at pausedAt, so elapsed is frozen there.
    final asOf =
        c.status == PomodoroStatus.paused ? c.pausedAt! : (now ?? c.startTime);
    final raw =
        asOf.difference(c.startTime).inSeconds - c.accumulatedPauseSeconds;
    return raw < 0 ? 0 : raw;
  }

  int get remainingSeconds {
    final c = current;
    if (c == null) return 0;
    final total = c.durasiMenit * 60;
    final r = total - elapsedSeconds;
    return r < 0 ? 0 : r;
  }

  bool get isOvertime =>
      current != null && elapsedSeconds > current!.durasiMenit * 60;

  PomodoroState copyWith({
    PomodoroSessionRow? current,
    bool clearCurrent = false,
    DateTime? now,
    UserSettingsRow? settings,
    int? focusStreakSinceLongBreak,
    List<PomodoroSessionRow>? recentSessions,
    bool? loading,
    String? error,
    bool? busy,
  }) =>
      PomodoroState(
        current: clearCurrent ? null : (current ?? this.current),
        now: now ?? this.now,
        settings: settings ?? this.settings,
        focusStreakSinceLongBreak:
            focusStreakSinceLongBreak ?? this.focusStreakSinceLongBreak,
        recentSessions: recentSessions ?? this.recentSessions,
        loading: loading ?? this.loading,
        error: error,
        busy: busy ?? this.busy,
      );
}
