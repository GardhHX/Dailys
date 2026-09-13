import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';
import '../db/tables/enums.dart';
import '../ids/deterministic_id.dart';
import '../time/local_date.dart';
import '../time/tz_resolver.dart';

/// Result of materializing one `ActivityRecurrence` template's rolling window
/// (schema.md Section 2; API-SPEC "Materializer berjalan pada...").
class RecurrenceMaterializationResult {
  const RecurrenceMaterializationResult({
    required this.occurrences,
    required this.materializedThroughDate,
  });

  /// New occurrence rows to insert. Callers MUST use insert-or-ignore: an
  /// occurrence already materialized for a date is an immutable snapshot of
  /// time/title/category/reminders and must never be overwritten by a later
  /// run, even if the template changed since ("Perubahan template hanya
  /// berlaku untuk occurrence yang belum dibuat" — API-SPEC 9.x).
  final List<ActivityCompanion> occurrences;

  /// The template's new `materialized_through_date` watermark after this run,
  /// or null if nothing changed (template not yet active within the window, or
  /// already ended before `today`) — the caller should leave the stored
  /// watermark untouched in that case.
  final LocalDate? materializedThroughDate;
}

/// Materializes `ActivityRecurrence` templates into concrete `Activity`
/// occurrence rows using the rolling-window contract (schema.md Section 2,
/// API-SPEC "Materializer" section).
///
/// Pure and deterministic: given the same template, timezone, and "today", it
/// always proposes the same occurrence ids and instants, so client and server
/// (and repeated local runs, per API-SPEC "Materializer berjalan pada app
/// start, sesudah pull, sesudah template berubah, dan setiap pergantian hari
/// lokal") converge without ever mutating an already-materialized row. Callers
/// own persistence and MUST insert-or-ignore (see [RecurrenceMaterializationResult]).
class RecurrenceMaterializer {
  const RecurrenceMaterializer._();

  /// `horizon_end = today + max(30, ceil(max_reminder_offset_minutes / 1440) + 1)`
  /// days (schema Section 2). An empty reminder array still yields 30 days.
  static int horizonDays(List<int> reminderOffsetsMinutes) {
    final maxOffset =
        reminderOffsetsMinutes.isEmpty ? 0 : reminderOffsetsMinutes.reduce(math.max);
    final days = (maxOffset / 1440).ceil() + 1;
    return math.max(30, days);
  }

  /// Computes the occurrences to (idempotently) insert for [template] as of
  /// [today] in [location], and the watermark to store back on the template
  /// afterward.
  ///
  /// The window is `[max(today, starts_on), min(horizon_end, ends_on)]`
  /// inclusive; dates before `today` are never (re)materialized even if
  /// `starts_on` is in the past — the rolling window only looks forward
  /// (schema Section 2: "rentang inklusif today...horizon_end").
  static RecurrenceMaterializationResult materialize({
    required ActivityRecurrenceRow template,
    required tz.Location location,
    required LocalDate today,
    DateTime? now,
  }) {
    final ts = now ?? DateTime.now().toUtc();
    final horizonEnd = today.addDays(horizonDays(template.reminderOffsetsMinutes));
    final startsOn = LocalDate.parse(template.startsOn);
    final endsOn = template.endsOn == null ? null : LocalDate.parse(template.endsOn!);

    final windowStart = today.isAfter(startsOn) ? today : startsOn;
    final windowEnd =
        endsOn == null ? horizonEnd : (endsOn.isBefore(horizonEnd) ? endsOn : horizonEnd);

    if (windowStart.isAfter(windowEnd)) {
      // Template not yet active within the window, or already ended.
      return const RecurrenceMaterializationResult(
        occurrences: [],
        materializedThroughDate: null,
      );
    }

    final recurringDays = template.recurringDays.toSet();
    final occurrences = <ActivityCompanion>[];
    for (var date = windowStart; !date.isAfter(windowEnd); date = date.addDays(1)) {
      if (!recurringDays.contains(date.weekday)) continue;
      occurrences.add(_buildOccurrence(template, location, date, ts));
    }

    return RecurrenceMaterializationResult(
      occurrences: occurrences,
      materializedThroughDate: windowEnd,
    );
  }

  static ActivityCompanion _buildOccurrence(
    ActivityRecurrenceRow template,
    tz.Location location,
    LocalDate date,
    DateTime ts,
  ) {
    // Local time `HH:mm:ss` (or `HH:mm`) -> Instant UTC, applying the DST
    // clamp/ambiguous policy (schema Section 2, 23.1).
    DateTime? toInstant(String? localTime) {
      if (localTime == null) return null;
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

    return ActivityCompanion.insert(
      id: DeterministicId.recurringActivity(template.id, date.toYmd()),
      createdAt: ts,
      updatedAt: ts,
      userId: template.userId,
      recurrenceId: Value(template.id),
      occurrenceDate: date.toYmd(),
      // Snapshot of title/category/time/reminders at materialization time
      // (schema Section 2: "snapshot immutable dari waktu, judul/kategori, dan
      // reminder template").
      judul: template.judul,
      activityCategoryId: template.activityCategoryId,
      startTime: Value(template.isAllDay ? null : toInstant(template.startTime)),
      endTime: Value(template.isAllDay ? null : toInstant(template.endTime)),
      isAllDay: Value(template.isAllDay),
      status: ActivityStatus.belum_mulai,
      source: ActivitySource.manual,
      reminderOffsetsMinutes: Value(List<int>.from(template.reminderOffsetsMinutes)),
      originDeviceId: Value(template.originDeviceId),
    );
  }
}
