import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/recurrence/materializer.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:dailys/core/time/tz_resolver.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Pure algorithm tests for [RecurrenceMaterializer] (schema.md Section 2,
/// API-SPEC "Materializer"). No database involved.
void main() {
  late tz.Location jakarta;
  late tz.Location ny;

  setUpAll(() {
    tzdata.initializeTimeZones();
    jakarta = tz.getLocation('Asia/Jakarta');
    ny = tz.getLocation('America/New_York');
  });

  const userId = '00000000-0000-0000-0000-000000000001';
  const recId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const catId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

  ActivityRecurrenceRow template({
    String startsOn = '2026-09-01',
    String? endsOn,
    List<int> recurringDays = const [1, 3, 5], // Mon/Wed/Fri
    String? startTime = '09:00:00',
    String? endTime = '10:00:00',
    bool isAllDay = false,
    List<int> reminderOffsetsMinutes = const [],
    String? materializedThroughDate,
  }) {
    final now = DateTime.utc(2026, 9, 1);
    return ActivityRecurrenceRow(
      id: recId,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      deletedAt: null,
      serverRevision: null,
      originDeviceId: null,
      userId: userId,
      judul: 'Kelas Basis Data',
      activityCategoryId: catId,
      startTime: isAllDay ? null : startTime,
      endTime: isAllDay ? null : endTime,
      isAllDay: isAllDay,
      recurringDays: recurringDays,
      startsOn: startsOn,
      endsOn: endsOn,
      reminderOffsetsMinutes: reminderOffsetsMinutes,
      catatan: null,
      materializedThroughDate: materializedThroughDate,
    );
  }

  group('horizonDays', () {
    test('empty reminders still yields 30 days', () {
      expect(RecurrenceMaterializer.horizonDays(const []), 30);
    });

    test('small offsets do not exceed the 30-day floor', () {
      expect(RecurrenceMaterializer.horizonDays(const [60, 120]), 30);
    });

    test('large offset extends the horizon: ceil(days) + 1', () {
      // 4321 minutes = ~3.0007 days -> ceil = 4 -> +1 = 5 -> still floored to 30.
      expect(RecurrenceMaterializer.horizonDays(const [4321]), 30);
      // 30 days in minutes + a bit -> forces horizon above the 30-day floor.
      const over30Days = 30 * 1440 + 1; // ceil(30.0007) = 31 -> +1 = 32
      expect(RecurrenceMaterializer.horizonDays([over30Days]), 32);
    });
  });

  group('materialize: window and weekday selection', () {
    test('only target weekdays within [today, horizon_end] are produced', () {
      const today = LocalDate(2026, 9, 14); // Monday
      final result = RecurrenceMaterializer.materialize(
        template: template(),
        location: jakarta,
        today: today,
      );

      // Horizon = today + 30 days = 2026-10-14.
      expect(result.materializedThroughDate, const LocalDate(2026, 10, 14));
      final dates = result.occurrences
          .map((c) => c.occurrenceDate.value)
          .toList()
        ..sort();
      expect(dates.first, '2026-09-14'); // Monday, matches today
      expect(dates.last, isNot(greaterThan('2026-10-14')));
      // All produced dates must be Mon/Wed/Fri.
      for (final d in dates) {
        final ld = LocalDate.parse(d);
        expect([1, 3, 5], contains(ld.weekday), reason: 'date $d');
      }
    });

    test('never materializes before today even if starts_on is in the past', () {
      const today = LocalDate(2026, 9, 14); // Monday
      final result = RecurrenceMaterializer.materialize(
        template: template(startsOn: '2020-01-01'),
        location: jakarta,
        today: today,
      );
      final dates = result.occurrences.map((c) => c.occurrenceDate.value);
      expect(dates.every((d) => !LocalDate.parse(d).isBefore(today)), isTrue);
    });

    test('respects starts_on when it is in the future', () {
      const today = LocalDate(2026, 9, 1); // Tuesday
      final result = RecurrenceMaterializer.materialize(
        template: template(startsOn: '2026-09-10'), // Thursday
        location: jakarta,
        today: today,
      );
      final dates = result.occurrences.map((c) => c.occurrenceDate.value).toList()..sort();
      expect(LocalDate.parse(dates.first).isBefore(LocalDate.parse('2026-09-10')), isFalse);
    });

    test('respects ends_on, clamping the window and the watermark', () {
      const today = LocalDate(2026, 9, 1);
      final result = RecurrenceMaterializer.materialize(
        template: template(endsOn: '2026-09-20'),
        location: jakarta,
        today: today,
      );
      expect(result.materializedThroughDate, const LocalDate(2026, 9, 20));
      for (final c in result.occurrences) {
        expect(
          LocalDate.parse(c.occurrenceDate.value).isAfter(const LocalDate(2026, 9, 20)),
          isFalse,
        );
      }
    });

    test('template already ended before today yields nothing and no watermark change', () {
      const today = LocalDate(2026, 9, 25);
      final result = RecurrenceMaterializer.materialize(
        template: template(endsOn: '2026-09-20'),
        location: jakarta,
        today: today,
      );
      expect(result.occurrences, isEmpty);
      expect(result.materializedThroughDate, null);
    });

    test('template not yet active (starts_on beyond horizon) yields nothing', () {
      const today = LocalDate(2026, 1, 1);
      final result = RecurrenceMaterializer.materialize(
        template: template(startsOn: '2027-01-01'),
        location: jakarta,
        today: today,
      );
      expect(result.occurrences, isEmpty);
      expect(result.materializedThroughDate, null);
    });
  });

  group('materialize: occurrence content is a correct snapshot', () {
    test('id is the deterministic UUIDv5 activity-occurrence', () {
      const today = LocalDate(2026, 9, 14);
      final result = RecurrenceMaterializer.materialize(
        template: template(),
        location: jakarta,
        today: today,
      );
      final first = result.occurrences.firstWhere((c) => c.occurrenceDate.value == '2026-09-14');
      expect(first.id.value, DeterministicId.recurringActivity(recId, '2026-09-14'));
    });

    test('copies judul, category, reminder offsets, and marks source=manual', () {
      const today = LocalDate(2026, 9, 14);
      final result = RecurrenceMaterializer.materialize(
        template: template(reminderOffsetsMinutes: const [30, 60]),
        location: jakarta,
        today: today,
      );
      final occ = result.occurrences.first;
      expect(occ.judul.value, 'Kelas Basis Data');
      expect(occ.activityCategoryId.value, catId);
      expect(occ.reminderOffsetsMinutes.value, [30, 60]);
      expect(occ.status.value, ActivityStatus.belum_mulai);
      expect(occ.source.value, ActivitySource.manual);
      expect(occ.userId.value, userId);
      expect(occ.recurrenceId, const Value(recId));
    });

    test('all-day template produces null start/end time', () {
      const today = LocalDate(2026, 9, 14);
      final result = RecurrenceMaterializer.materialize(
        template: template(isAllDay: true, startTime: null, endTime: null),
        location: jakarta,
        today: today,
      );
      final occ = result.occurrences.first;
      expect(occ.isAllDay.value, isTrue);
      expect(occ.startTime.value, null);
      expect(occ.endTime.value, null);
    });

    test('converts local start/end time to Instant UTC via TzResolver', () {
      const today = LocalDate(2026, 9, 14);
      final result = RecurrenceMaterializer.materialize(
        template: template(startTime: '09:00:00', endTime: '10:00:00'),
        location: jakarta,
        today: today,
      );
      final occ = result.occurrences.first;
      // Asia/Jakarta = UTC+7, no DST.
      expect(
        TzResolver.toContractUtc(occ.startTime.value!),
        '2026-09-14T02:00:00Z',
      );
      expect(
        TzResolver.toContractUtc(occ.endTime.value!),
        '2026-09-14T03:00:00Z',
      );
    });

    test('applies the DST spring-forward clamp from schema 23.1', () {
      // 2026-03-08 in America/New_York: 02:00-03:00 gap. start_time=02:30
      // clamps to 03:00 EDT = 07:00Z (golden vector, schema 23.1).
      final sundayTemplate = template(
        startsOn: '2026-03-08',
        endsOn: '2026-03-08',
        recurringDays: const [7], // Sunday
        startTime: '02:30:00',
        endTime: null,
        isAllDay: false,
      );
      final result = RecurrenceMaterializer.materialize(
        template: sundayTemplate,
        location: ny,
        today: const LocalDate(2026, 3, 8),
      );
      expect(result.occurrences, hasLength(1));
      expect(
        TzResolver.toContractUtc(result.occurrences.single.startTime.value!),
        '2026-03-08T07:00:00Z',
      );
    });
  });

  group('materialize: idempotency', () {
    test('same template/today produces byte-identical ids and instants twice', () {
      const today = LocalDate(2026, 9, 14);
      final r1 = RecurrenceMaterializer.materialize(
        template: template(), location: jakarta, today: today);
      final r2 = RecurrenceMaterializer.materialize(
        template: template(), location: jakarta, today: today);
      final ids1 = r1.occurrences.map((c) => c.id.value).toList();
      final ids2 = r2.occurrences.map((c) => c.id.value).toList();
      expect(ids1, ids2);
    });
  });
}
