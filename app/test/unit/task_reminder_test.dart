import 'package:dailys/core/time/local_date.dart';
import 'package:dailys/features/tugas/domain/task_reminder.dart';
import 'package:dailys/features/tugas/domain/tugas_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskReminder', () {
    test('defaults are H-7/H-3/H-1 at 09:00 plus 120 minutes (schema 5)', () {
      final d = TaskReminder.defaults();
      expect(d.map((r) => r.canonicalKey), [
        'calendar_day:7:09:00:00',
        'calendar_day:3:09:00:00',
        'calendar_day:1:09:00:00',
        'relative_minutes:120',
      ]);
    });

    test('round-trips through map form', () {
      for (final r in TaskReminder.defaults()) {
        expect(TaskReminder.fromMap(r.toMap()).canonicalKey, r.canonicalKey);
      }
    });

    test('dedupe drops canonical duplicates, keeps first order', () {
      final deduped = TaskReminder.dedupe(const [
        CalendarDayReminder(daysBefore: 1, localTime: '09:00:00'),
        RelativeMinutesReminder(minutesBefore: 120),
        CalendarDayReminder(daysBefore: 1, localTime: '09:00:00'), // dup
      ]);
      expect(deduped, hasLength(2));
      expect(deduped.first.canonicalKey, 'calendar_day:1:09:00:00');
    });

    test('unknown kind is rejected', () {
      expect(() => TaskReminder.fromMap({'kind': 'nope'}), throwsFormatException);
    });

    test('calendar_day fires days_before the deadline Local date', () {
      const r = CalendarDayReminder(daysBefore: 3, localTime: '09:00:00');
      expect(r.fireDate(const LocalDate(2026, 9, 14)), const LocalDate(2026, 9, 11));
    });
  });

  group('WeekRange', () {
    test('of() snaps to the containing Monday and spans 7 days', () {
      // 2026-09-16 is a Wednesday.
      final w = WeekRange.of(const LocalDate(2026, 9, 16));
      expect(w.monday, const LocalDate(2026, 9, 14)); // Monday
      expect(w.sunday, const LocalDate(2026, 9, 20)); // Sunday
    });

    test('contains covers Monday..Sunday inclusive', () {
      final w = WeekRange.of(const LocalDate(2026, 9, 14));
      expect(w.contains(const LocalDate(2026, 9, 14)), isTrue);
      expect(w.contains(const LocalDate(2026, 9, 20)), isTrue);
      expect(w.contains(const LocalDate(2026, 9, 21)), isFalse);
      expect(w.contains(const LocalDate(2026, 9, 13)), isFalse);
    });

    test('previous/next shift by a whole week', () {
      final w = WeekRange.of(const LocalDate(2026, 9, 14));
      expect(w.previous.monday, const LocalDate(2026, 9, 7));
      expect(w.next.monday, const LocalDate(2026, 9, 21));
    });
  });
}
