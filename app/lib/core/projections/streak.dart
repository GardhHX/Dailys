import '../db/tables/enums.dart';
import '../time/local_date.dart';

/// One HabitSchedule version, reduced to the fields the evaluator needs
/// (schema 11.1).
class HabitScheduleWindow {
  const HabitScheduleWindow({
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.targetHari,
    required this.maxIzinPerMinggu,
    required this.state,
  });

  final LocalDate effectiveFrom;
  final LocalDate? effectiveTo;
  final Set<int> targetHari;
  final int maxIzinPerMinggu;
  final HabitScheduleState state;

  bool covers(LocalDate date) =>
      !date.isBefore(effectiveFrom) &&
      (effectiveTo == null || !date.isAfter(effectiveTo!));
}

/// One HabitLog row, reduced to the fields the evaluator needs (schema 11.2).
class HabitLogEntry {
  const HabitLogEntry({required this.tanggal, required this.status});

  final LocalDate tanggal;
  final HabitLogStatus status;
}

/// Result of [evaluateHabitStreak]: `current_streak`/`longest_streak` cache
/// values (schema 11 / 11.3).
class HabitStreakResult {
  const HabitStreakResult(
      {required this.currentStreak, required this.longestStreak});

  final int currentStreak;
  final int longestStreak;
}

/// Pure-function streak evaluator matching schema.md 11.3 "Algoritma streak
/// normatif" exactly (golden table). DB-agnostic, like
/// `core/projections/completion_rate.dart` and `overlap.dart` — callers
/// (`HabitDao`) supply the schedule/log rows and the evaluator recomputes
/// from `effective_from` of the earliest schedule through [today], both in
/// `UserSettings.timezone` Local date terms.
///
/// - Days with no covering schedule, or covered by a `paused` schedule, are
///   ignored (neither add nor break).
/// - Non-target weekdays are ignored.
/// - `done` on a target day adds one and can raise `longest_streak`; an
///   unlogged [today] never does (it simply leaves the running count as-is
///   without confirming it), so `longest_streak` only reflects days that
///   already have a recorded outcome.
/// - `skip` on a target day is excused only while the Monday–Sunday weekly
///   count of excused skips under the schedule active on that date stays
///   below `max_izin_per_minggu`; excess skips break the streak like
///   `missed`.
/// - `missed`, or a past target day with no log at all, breaks the streak to
///   zero. A target day of [today] with no log yet does not break it.
HabitStreakResult evaluateHabitStreak({
  required List<HabitScheduleWindow> schedules,
  required List<HabitLogEntry> logs,
  required LocalDate today,
}) {
  if (schedules.isEmpty) {
    return const HabitStreakResult(currentStreak: 0, longestStreak: 0);
  }
  final sorted = [...schedules]
    ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
  final firstDate = sorted.first.effectiveFrom;
  if (firstDate.isAfter(today)) {
    return const HabitStreakResult(currentStreak: 0, longestStreak: 0);
  }
  final logByDate = <String, HabitLogEntry>{
    for (final log in logs) log.tanggal.toYmd(): log,
  };
  final weekSkipUsed = <String, int>{};

  var run = 0;
  var longest = 0;
  var d = firstDate;
  while (!d.isAfter(today)) {
    final schedule = _scheduleCovering(sorted, d);
    final isToday = d == today;
    if (schedule == null || schedule.state == HabitScheduleState.paused) {
      d = d.addDays(1);
      continue;
    }
    if (!schedule.targetHari.contains(d.weekday)) {
      d = d.addDays(1);
      continue;
    }
    final log = logByDate[d.toYmd()];
    final status = log?.status;
    if (status == HabitLogStatus.done) {
      run += 1;
      if (run > longest) longest = run;
    } else if (status == HabitLogStatus.skip) {
      final weekKey = _mondayOf(d).toYmd();
      final used = weekSkipUsed[weekKey] ?? 0;
      if (used < schedule.maxIzinPerMinggu) {
        weekSkipUsed[weekKey] = used + 1;
      } else {
        run = 0;
      }
    } else if (status == HabitLogStatus.missed) {
      run = 0;
    } else if (!isToday) {
      run = 0;
    }
    d = d.addDays(1);
  }
  return HabitStreakResult(currentStreak: run, longestStreak: longest);
}

HabitScheduleWindow? _scheduleCovering(
    List<HabitScheduleWindow> sortedSchedules, LocalDate date) {
  for (final schedule in sortedSchedules) {
    if (schedule.covers(date)) return schedule;
  }
  return null;
}

LocalDate _mondayOf(LocalDate date) => date.addDays(-(date.weekday - 1));
