import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/projections/pomodoro_stats.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Pure tests for `groupPomodoroByDay`/`aggregatePomodoroPeriod` (schema 9,
/// FR-2.10/2.11): "total actual_seconds dan jumlah sesi, dikelompokkan
/// menurut Local date start_time".
void main() {
  late tz.Location jakarta;
  setUpAll(() {
    tzdata.initializeTimeZones();
    jakarta = tz.getLocation('Asia/Jakarta');
  });

  const userId = '00000000-0000-0000-0000-000000000001';

  PomodoroSessionRow session({
    required String id,
    required DateTime startTime,
    required int actualSeconds,
    PomodoroJenis jenis = PomodoroJenis.fokus,
    PomodoroStatus status = PomodoroStatus.completed,
  }) =>
      PomodoroSessionRow(
        id: id,
        createdAt: startTime,
        updatedAt: startTime,
        isDeleted: false,
        deletedAt: null,
        serverRevision: null,
        originDeviceId: null,
        userId: userId,
        tugasId: null,
        habitId: null,
        startTime: startTime,
        endTime: startTime.add(Duration(seconds: actualSeconds)),
        pausedAt: null,
        accumulatedPauseSeconds: 0,
        durasiMenit: 25,
        actualSeconds: actualSeconds,
        jenis: jenis,
        status: status,
      );

  test('groups sessions by Local date and sums actual_seconds/count', () {
    final sessions = [
      // Both 09:00 and 23:30 WIB on 2026-09-07.
      session(id: '1', startTime: DateTime.utc(2026, 9, 7, 2), actualSeconds: 1500),
      session(id: '2', startTime: DateTime.utc(2026, 9, 7, 16, 30), actualSeconds: 1200),
      // 2026-09-08 00:30 WIB = 2026-09-07 17:30 UTC -> different Local date.
      session(id: '3', startTime: DateTime.utc(2026, 9, 7, 17, 30), actualSeconds: 900),
    ];

    final daily = groupPomodoroByDay(sessions, jakarta);
    expect(daily, hasLength(2));

    final sept7 = daily.firstWhere((d) => d.date == const LocalDate(2026, 9, 7));
    expect(sept7.totalActualSeconds, 2700);
    expect(sept7.sessionCount, 2);

    final sept8 = daily.firstWhere((d) => d.date == const LocalDate(2026, 9, 8));
    expect(sept8.totalActualSeconds, 900);
    expect(sept8.sessionCount, 1);
  });

  test('aggregatePomodoroPeriod sums the daily stats within an inclusive range', () {
    final daily = [
      const PomodoroDailyStat(
          date: LocalDate(2026, 9, 1), totalActualSeconds: 600, sessionCount: 1),
      const PomodoroDailyStat(
          date: LocalDate(2026, 9, 5), totalActualSeconds: 900, sessionCount: 2),
      const PomodoroDailyStat(
          date: LocalDate(2026, 9, 10), totalActualSeconds: 300, sessionCount: 1),
    ];

    final week = aggregatePomodoroPeriod(daily,
        periodStart: const LocalDate(2026, 9, 1), periodEnd: const LocalDate(2026, 9, 7));
    expect(week.totalActualSeconds, 1500);
    expect(week.sessionCount, 3);

    final outsideAll = aggregatePomodoroPeriod(daily,
        periodStart: const LocalDate(2026, 9, 20), periodEnd: const LocalDate(2026, 9, 21));
    expect(outsideAll.totalActualSeconds, 0);
    expect(outsideAll.sessionCount, 0);
  });
}
