import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/recurrence/timebox_materializer.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:dailys/core/time/tz_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Pure algorithm tests for [TimeboxMaterializer] (schema.md Section 10/10.1).
/// No database involved — mirrors `materializer_test.dart`.
void main() {
  late tz.Location jakarta;
  setUpAll(() {
    tzdata.initializeTimeZones();
    jakarta = tz.getLocation('Asia/Jakarta');
  });

  const userId = '00000000-0000-0000-0000-000000000001';
  const scheduleId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const catId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  final createdAt = DateTime.utc(2026, 9, 1);

  TimeboxScheduleRow schedule({
    bool isRecurring = true,
    int? hari = 1, // Monday
    String? tanggalSpesifik,
    bool isActive = true,
    List<int> reminderOffsetsMinutes = const [],
  }) =>
      TimeboxScheduleRow(
        id: scheduleId,
        createdAt: createdAt,
        updatedAt: createdAt,
        isDeleted: false,
        deletedAt: null,
        serverRevision: null,
        originDeviceId: null,
        userId: userId,
        tugasId: null,
        habitId: null,
        judul: 'Kelas Basis Data',
        activityCategoryId: catId,
        startTime: '09:00:00',
        endTime: '10:00:00',
        hari: hari,
        tanggalSpesifik: tanggalSpesifik,
        isRecurring: isRecurring,
        isActive: isActive,
        reminderOffsetsMinutes: reminderOffsetsMinutes,
        materializedThroughDate: null,
      );

  group('recurring', () {
    test('produces one execution per matching weekday within the horizon', () {
      const today = LocalDate(2026, 9, 7); // Monday
      final result = TimeboxMaterializer.materialize(
        schedule: schedule(hari: 1),
        location: jakarta,
        today: today,
      );
      // 30-day horizon with an empty reminder array; Mondays in [9/7, 10/7].
      expect(result.executions, isNotEmpty);
      expect(result.materializedThroughDate, today.addDays(30));
      for (final exec in result.executions) {
        final local = tz.TZDateTime.from(exec.plannedStartAt.value, jakarta);
        expect(local.weekday, DateTime.monday);
        expect(exec.status.value, TimeboxExecutionStatus.pending);
      }
    });

    test('is deterministic: same inputs -> same execution ids', () {
      const today = LocalDate(2026, 9, 7);
      final a = TimeboxMaterializer.materialize(
          schedule: schedule(hari: 1), location: jakarta, today: today);
      final b = TimeboxMaterializer.materialize(
          schedule: schedule(hari: 1), location: jakarta, today: today);
      expect(a.executions.map((e) => e.id.value).toList(),
          b.executions.map((e) => e.id.value).toList());
    });

    test('execution id matches DeterministicId.timeboxExecution', () {
      const today = LocalDate(2026, 9, 7);
      final result = TimeboxMaterializer.materialize(
          schedule: schedule(hari: 1), location: jakarta, today: today);
      final first = result.executions.first;
      expect(
        first.id.value,
        DeterministicId.timeboxExecution(
            scheduleId, TzResolver.toContractUtc(first.plannedStartAt.value)),
      );
    });

    test('is_active = false halts materialization entirely (FR-3.12)', () {
      final result = TimeboxMaterializer.materialize(
        schedule: schedule(hari: 1, isActive: false),
        location: jakarta,
        today: const LocalDate(2026, 9, 7),
      );
      expect(result.executions, isEmpty);
      expect(result.materializedThroughDate, isNull);
    });

    test('never materializes a date before "today" (forward-only window)', () {
      const today = LocalDate(2026, 9, 7);
      final result = TimeboxMaterializer.materialize(
        schedule: schedule(hari: 1),
        location: jakarta,
        today: today,
      );
      for (final exec in result.executions) {
        final localDate =
            LocalDate.fromInstant(exec.plannedStartAt.value, jakarta);
        expect(localDate.isBefore(today), isFalse);
      }
    });
  });

  group('ad-hoc', () {
    test('produces exactly one execution on tanggal_spesifik', () {
      final result = TimeboxMaterializer.materialize(
        schedule:
            schedule(isRecurring: false, hari: null, tanggalSpesifik: '2026-09-20'),
        location: jakarta,
        today: const LocalDate(2026, 9, 7),
      );
      expect(result.executions, hasLength(1));
      final exec = result.executions.single;
      expect(exec.occurrenceDate.value, '2026-09-20');
      final localStart = tz.TZDateTime.from(exec.plannedStartAt.value, jakarta);
      expect(localStart.hour, 9);
      expect(result.materializedThroughDate, const LocalDate(2026, 9, 20));
    });

    test('is_active = false halts an ad-hoc block too', () {
      final result = TimeboxMaterializer.materialize(
        schedule: schedule(
            isRecurring: false, hari: null, tanggalSpesifik: '2026-09-20', isActive: false),
        location: jakarta,
        today: const LocalDate(2026, 9, 7),
      );
      expect(result.executions, isEmpty);
    });
  });

  group('DST (reuses TzResolver, same policy as Activity — schema 23.1)', () {
    test('spring-forward gap clamps forward', () {
      final ny = tz.getLocation('America/New_York');
      // 2026-03-08 02:30 local doesn't exist in America/New_York (spring
      // forward at 02:00 -> 03:00); TzResolver clamps to the transition.
      final result = TimeboxMaterializer.materialize(
        schedule: TimeboxScheduleRow(
          id: scheduleId,
          createdAt: createdAt,
          updatedAt: createdAt,
          isDeleted: false,
          deletedAt: null,
          serverRevision: null,
          originDeviceId: null,
          userId: userId,
          tugasId: null,
          habitId: null,
          judul: 'DST Block',
          activityCategoryId: catId,
          startTime: '02:30:00',
          endTime: '03:30:00',
          hari: null,
          tanggalSpesifik: '2026-03-08',
          isRecurring: false,
          isActive: true,
          reminderOffsetsMinutes: const [],
          materializedThroughDate: null,
        ),
        location: ny,
        today: const LocalDate(2026, 3, 1),
      );
      expect(result.executions.single.plannedStartAt.value,
          DateTime.utc(2026, 3, 8, 7, 0, 0));
    });
  });
}
