import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';
import '../time/local_date.dart';

/// One Local date's aggregate of completed `fokus` PomodoroSessions (schema
/// 9, FR-2.10): "total `actual_seconds` dan jumlah sesi, dikelompokkan
/// menurut Local date `start_time`".
class PomodoroDailyStat {
  const PomodoroDailyStat({
    required this.date,
    required this.totalActualSeconds,
    required this.sessionCount,
  });

  final LocalDate date;
  final int totalActualSeconds;
  final int sessionCount;
}

/// Groups completed `fokus` sessions by the Local date of `start_time` in
/// [location] (schema 9). Callers must pre-filter to `jenis=fokus` and
/// `status=completed` — this is a pure grouping function, not a query (same
/// division of labor as `findOverlaps`/`completionRatePercent`); see
/// `PomodoroDao.getCompletedFocusSessions`.
List<PomodoroDailyStat> groupPomodoroByDay(
    List<PomodoroSessionRow> completedFocusSessions, tz.Location location) {
  final totals = <String, int>{};
  final counts = <String, int>{};
  for (final s in completedFocusSessions) {
    final date = LocalDate.fromInstant(s.startTime, location);
    final key = date.toYmd();
    totals[key] = (totals[key] ?? 0) + (s.actualSeconds ?? 0);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final stats = totals.keys
      .map((key) => PomodoroDailyStat(
            date: LocalDate.parse(key),
            totalActualSeconds: totals[key]!,
            sessionCount: counts[key]!,
          ))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return stats;
}

/// FR-2.11: the same daily/weekly/monthly aggregation rule applied to an
/// inclusive `[periodStart, periodEnd]` Local date range — a weekly or
/// monthly total is just this rule over a wider window than one day.
class PomodoroPeriodStat {
  const PomodoroPeriodStat({
    required this.periodStart,
    required this.periodEnd,
    required this.totalActualSeconds,
    required this.sessionCount,
  });

  final LocalDate periodStart;
  final LocalDate periodEnd;
  final int totalActualSeconds;
  final int sessionCount;
}

PomodoroPeriodStat aggregatePomodoroPeriod(
  List<PomodoroDailyStat> daily, {
  required LocalDate periodStart,
  required LocalDate periodEnd,
}) {
  var totalSeconds = 0;
  var totalCount = 0;
  for (final d in daily) {
    if (d.date.isBefore(periodStart) || d.date.isAfter(periodEnd)) continue;
    totalSeconds += d.totalActualSeconds;
    totalCount += d.sessionCount;
  }
  return PomodoroPeriodStat(
    periodStart: periodStart,
    periodEnd: periodEnd,
    totalActualSeconds: totalSeconds,
    sessionCount: totalCount,
  );
}
