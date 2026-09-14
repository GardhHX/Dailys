import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';
import '../db/tables/enums.dart';
import '../ids/deterministic_id.dart';
import '../time/local_date.dart';
import '../time/tz_resolver.dart';
import 'materializer.dart';

/// Result of materializing one `TimeboxSchedule`'s occurrences (schema.md
/// Section 10/10.1), mirroring [RecurrenceMaterializationResult].
class TimeboxMaterializationResult {
  const TimeboxMaterializationResult({
    required this.executions,
    required this.materializedThroughDate,
  });

  /// New execution rows to insert. Callers MUST use insert-or-ignore: an
  /// execution already materialized for a `planned_start_at` is an immutable
  /// snapshot (schema 10.1: "selalu diisi ... saat execution dimaterialisasi
  /// ... bukan live join ke schedule") and must never be overwritten by a
  /// later run even if the template changed since.
  final List<TimeboxExecutionCompanion> executions;

  /// The template's new `materialized_through_date` watermark after this run,
  /// or null if nothing changed.
  final LocalDate? materializedThroughDate;
}

/// Materializes `TimeboxSchedule` templates into concrete `TimeboxExecution`
/// rows (schema.md Section 10/10.1), generalizing [RecurrenceMaterializer]'s
/// rolling-window contract to Timebox's two shapes:
///
///  - **recurring**: one weekday (`hari`, not a day *set* like
///    ActivityRecurrence.recurring_days — schema 10 gives Timebox a single
///    `hari` per schedule row, so "Senin dan Rabu" is two schedule rows), open
///    -ended (no `starts_on`/`ends_on` on TimeboxSchedule), walked forward from
///    `today` through the same horizon formula Activity recurrence uses.
///  - **ad-hoc**: exactly one occurrence on `tanggal_spesifik`, materialized
///    unconditionally rather than windowed — there is only ever one date, so
///    the "never look backward" rolling-window rule (which exists to avoid
///    bulk-creating recurring history) doesn't apply to it.
///
/// `is_active = false` halts materialization entirely for the schedule
/// (FR-3.12) without touching executions already materialized.
///
/// Pure and deterministic like [RecurrenceMaterializer]: same inputs always
/// propose the same execution ids/instants, so repeated local runs (and,
/// eventually, the server) converge without ever mutating an already
/// -materialized row. Callers own persistence and MUST insert-or-ignore.
class TimeboxMaterializer {
  const TimeboxMaterializer._();

  static TimeboxMaterializationResult materialize({
    required TimeboxScheduleRow schedule,
    required tz.Location location,
    required LocalDate today,
    DateTime? now,
  }) {
    if (!schedule.isActive) {
      return const TimeboxMaterializationResult(
        executions: [],
        materializedThroughDate: null,
      );
    }
    final ts = now ?? DateTime.now().toUtc();

    if (!schedule.isRecurring) {
      final date = LocalDate.parse(schedule.tanggalSpesifik!);
      return TimeboxMaterializationResult(
        executions: [_buildExecution(schedule, location, date, ts)],
        materializedThroughDate: date,
      );
    }

    // Recurring: open-ended (no starts_on/ends_on), so the window always runs
    // from today through the horizon — same forward-only rule as Activity
    // recurrence (schema Section 2): dates before today are never
    // (re)materialized.
    final horizonEnd =
        today.addDays(RecurrenceMaterializer.horizonDays(schedule.reminderOffsetsMinutes));
    final executions = <TimeboxExecutionCompanion>[];
    for (var date = today; !date.isAfter(horizonEnd); date = date.addDays(1)) {
      if (date.weekday != schedule.hari) continue;
      executions.add(_buildExecution(schedule, location, date, ts));
    }
    return TimeboxMaterializationResult(
      executions: executions,
      materializedThroughDate: horizonEnd,
    );
  }

  static TimeboxExecutionCompanion _buildExecution(
    TimeboxScheduleRow schedule,
    tz.Location location,
    LocalDate date,
    DateTime ts,
  ) {
    DateTime toInstant(String localTime) {
      final parts = localTime.split(':');
      return TzResolver.localToUtc(
        location,
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        parts.length > 2 ? int.parse(parts[2]) : 0,
      );
    }

    final plannedStart = toInstant(schedule.startTime);
    final plannedEnd = toInstant(schedule.endTime);
    return TimeboxExecutionCompanion.insert(
      id: DeterministicId.timeboxExecution(
        schedule.id,
        TzResolver.toContractUtc(plannedStart),
      ),
      createdAt: ts,
      updatedAt: ts,
      scheduleId: schedule.id,
      occurrenceDate: date.toYmd(),
      plannedStartAt: plannedStart,
      plannedEndAt: plannedEnd,
      status: TimeboxExecutionStatus.pending,
      originDeviceId: Value(schedule.originDeviceId),
    );
  }
}
