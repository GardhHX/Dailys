import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/projections/streak.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden table from schema.md 11.3 "Algoritma streak normatif" (timezone
/// `Asia/Jakarta`) — also design/screens/habit.md's normative fixture. Each
/// row is the cache snapshot from an independent `evaluateHabitStreak` call
/// with `today` at that row's date (or, when the row documents a break that
/// only becomes visible once the day has fully elapsed, the day after —
/// see the 09-14 row below). This mirrors `HabitDao`'s real recompute calls,
/// each made with whatever "today" is current at the time.
///
/// | Tanggal        | Schedule/state        | Log                          | current | longest |
/// |----------------|------------------------|-------------------------------|--------:|--------:|
/// | Sen 2026-09-07 | active `[1,3,5]`       | done                          |       1 |       1 |
/// | Rab 2026-09-09 | active `[1,3,5]`       | skip valid                    |       1 |       1 |
/// | Jum 2026-09-11 | active `[1,3,5]`       | done                          |       2 |       2 |
/// | Sen 2026-09-14 | active `[1,3,5]`       | none after day ends          |       0 |       2 |
/// | Rab 2026-09-16 | active `[1,3,5]`       | done                          |       1 |       2 |
/// | Sen 2026-09-21 | paused                | none                          |       1 |       2 |
/// | Sel 2026-09-29 | active `[2,4]`         | done                          |       2 |       2 |
///
/// Dart, Node.js, and the recompute migration must all reproduce this table.
void main() {
  final schedule1 = HabitScheduleWindow(
    effectiveFrom: LocalDate.parse('2026-09-07'),
    effectiveTo: LocalDate.parse('2026-09-16'),
    targetHari: const {1, 3, 5},
    maxIzinPerMinggu: 1,
    state: HabitScheduleState.active,
  );
  final schedule1Open = HabitScheduleWindow(
    effectiveFrom: LocalDate.parse('2026-09-07'),
    effectiveTo: null,
    targetHari: const {1, 3, 5},
    maxIzinPerMinggu: 1,
    state: HabitScheduleState.active,
  );
  final schedule2Paused = HabitScheduleWindow(
    effectiveFrom: LocalDate.parse('2026-09-17'),
    effectiveTo: LocalDate.parse('2026-09-28'),
    targetHari: const {1, 3, 5},
    maxIzinPerMinggu: 1,
    state: HabitScheduleState.paused,
  );
  final schedule2PausedOpen = HabitScheduleWindow(
    effectiveFrom: LocalDate.parse('2026-09-17'),
    effectiveTo: null,
    targetHari: const {1, 3, 5},
    maxIzinPerMinggu: 1,
    state: HabitScheduleState.paused,
  );
  final schedule3 = HabitScheduleWindow(
    effectiveFrom: LocalDate.parse('2026-09-29'),
    effectiveTo: null,
    targetHari: const {2, 4},
    maxIzinPerMinggu: 1,
    state: HabitScheduleState.active,
  );

  final logDone7 = HabitLogEntry(
      tanggal: LocalDate.parse('2026-09-07'), status: HabitLogStatus.done);
  final logSkip9 = HabitLogEntry(
      tanggal: LocalDate.parse('2026-09-09'), status: HabitLogStatus.skip);
  final logDone11 = HabitLogEntry(
      tanggal: LocalDate.parse('2026-09-11'), status: HabitLogStatus.done);
  final logDone16 = HabitLogEntry(
      tanggal: LocalDate.parse('2026-09-16'), status: HabitLogStatus.done);
  final logDone29 = HabitLogEntry(
      tanggal: LocalDate.parse('2026-09-29'), status: HabitLogStatus.done);

  test('Habit streak evaluator matches the schema 11.3 golden table', () {
    // Sen 2026-09-07: done -> current=1, longest=1.
    var result = evaluateHabitStreak(
      schedules: [schedule1Open],
      logs: [logDone7],
      today: LocalDate.parse('2026-09-07'),
    );
    expect(result.currentStreak, 1);
    expect(result.longestStreak, 1);

    // Rab 2026-09-09: skip within weekly quota -> excused, current=1.
    result = evaluateHabitStreak(
      schedules: [schedule1Open],
      logs: [logDone7, logSkip9],
      today: LocalDate.parse('2026-09-09'),
    );
    expect(result.currentStreak, 1);
    expect(result.longestStreak, 1);

    // Jum 2026-09-11: done -> current=2, longest=2.
    result = evaluateHabitStreak(
      schedules: [schedule1Open],
      logs: [logDone7, logSkip9, logDone11],
      today: LocalDate.parse('2026-09-11'),
    );
    expect(result.currentStreak, 2);
    expect(result.longestStreak, 2);

    // Sen 2026-09-14: target day, no log. "None after day ends" means this
    // is read back once 09-14 is no longer today (`today` here is 09-15) --
    // while 09-14 itself is still today, a missing log never breaks the
    // streak (schema 11.3 rule 6). Breaks to 0; longest keeps the earlier
    // peak.
    result = evaluateHabitStreak(
      schedules: [schedule1Open],
      logs: [logDone7, logSkip9, logDone11],
      today: LocalDate.parse('2026-09-15'),
    );
    expect(result.currentStreak, 0);
    expect(result.longestStreak, 2);

    // Rab 2026-09-16: done -> current=1 (fresh run), longest still 2.
    result = evaluateHabitStreak(
      schedules: [schedule1Open],
      logs: [logDone7, logSkip9, logDone11, logDone16],
      today: LocalDate.parse('2026-09-16'),
    );
    expect(result.currentStreak, 1);
    expect(result.longestStreak, 2);

    // Sen 2026-09-21: paused since 09-17 -> target days ignored, current
    // holds at 1 from 09-16, longest still 2.
    result = evaluateHabitStreak(
      schedules: [schedule1, schedule2PausedOpen],
      logs: [logDone7, logSkip9, logDone11, logDone16],
      today: LocalDate.parse('2026-09-21'),
    );
    expect(result.currentStreak, 1);
    expect(result.longestStreak, 2);

    // Sel 2026-09-29: new active schedule `[2,4]`, done -> current=2 (1 held
    // through the pause + this done), longest still 2 (today excluded).
    result = evaluateHabitStreak(
      schedules: [schedule1, schedule2Paused, schedule3],
      logs: [logDone7, logSkip9, logDone11, logDone16, logDone29],
      today: LocalDate.parse('2026-09-29'),
    );
    expect(result.currentStreak, 2);
    expect(result.longestStreak, 2);
  });

  test('skip beyond weekly quota breaks the streak like missed', () {
    final schedule = HabitScheduleWindow(
      effectiveFrom: LocalDate.parse('2026-09-07'),
      effectiveTo: null,
      targetHari: const {1, 3, 5},
      maxIzinPerMinggu: 1,
      state: HabitScheduleState.active,
    );
    final result = evaluateHabitStreak(
      schedules: [schedule],
      logs: [
        HabitLogEntry(
            tanggal: LocalDate.parse('2026-09-07'),
            status: HabitLogStatus.done),
        HabitLogEntry(
            tanggal: LocalDate.parse('2026-09-09'),
            status: HabitLogStatus.skip),
        // Second skip in the same Mon-Sun week exceeds max_izin_per_minggu=1.
        HabitLogEntry(
            tanggal: LocalDate.parse('2026-09-11'),
            status: HabitLogStatus.skip),
      ],
      today: LocalDate.parse('2026-09-11'),
    );
    expect(result.currentStreak, 0);
    expect(result.longestStreak, 1);
  });

  test('empty schedule history yields a zero streak', () {
    final result = evaluateHabitStreak(
      schedules: const [],
      logs: const [],
      today: LocalDate.parse('2026-09-07'),
    );
    expect(result.currentStreak, 0);
    expect(result.longestStreak, 0);
  });
}
