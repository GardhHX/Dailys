import '../../../core/time/local_date.dart';

/// A typed Tugas reminder (schema 5). Two shapes:
///
/// - `calendar_day`: fires on the deadline's Local date minus [daysBefore] at
///   [localTime] in the user timezone;
/// - `relative_minutes`: fires [minutesBefore] before the deadline Instant.
///
/// Serialized as one object inside `Tugas.reminders`. Canonical duplicates are
/// rejected (schema 5); [canonicalKey] defines that identity.
sealed class TaskReminder {
  const TaskReminder();

  factory TaskReminder.fromMap(Map<String, Object?> map) {
    final kind = map['kind'];
    switch (kind) {
      case 'calendar_day':
        return CalendarDayReminder(
          daysBefore: (map['days_before'] as num).toInt(),
          localTime: map['local_time'] as String,
        );
      case 'relative_minutes':
        return RelativeMinutesReminder(
          minutesBefore: (map['minutes_before'] as num).toInt(),
        );
      default:
        throw FormatException('unknown TaskReminder kind: $kind');
    }
  }

  Map<String, Object?> toMap();

  /// Identity used to reject canonical duplicates (schema 5).
  String get canonicalKey;

  /// Default reminder set for a new task (schema 5): H-7/H-3/H-1 at 09:00 plus
  /// 120 minutes before the deadline.
  static List<TaskReminder> defaults() => const [
        CalendarDayReminder(daysBefore: 7, localTime: '09:00:00'),
        CalendarDayReminder(daysBefore: 3, localTime: '09:00:00'),
        CalendarDayReminder(daysBefore: 1, localTime: '09:00:00'),
        RelativeMinutesReminder(minutesBefore: 120),
      ];

  /// Drops canonical duplicates, keeping first occurrence (schema 5).
  static List<TaskReminder> dedupe(Iterable<TaskReminder> reminders) {
    final seen = <String>{};
    final out = <TaskReminder>[];
    for (final r in reminders) {
      if (seen.add(r.canonicalKey)) out.add(r);
    }
    return out;
  }

  static List<TaskReminder> fromJsonList(List<Map<String, Object?>> rows) =>
      rows.map(TaskReminder.fromMap).toList(growable: false);

  static List<Map<String, Object?>> toJsonList(Iterable<TaskReminder> reminders) =>
      reminders.map((r) => r.toMap()).toList(growable: false);
}

class CalendarDayReminder extends TaskReminder {
  const CalendarDayReminder({required this.daysBefore, required this.localTime});

  final int daysBefore;

  /// `HH:mm:ss` in the user timezone.
  final String localTime;

  /// Local date this reminder fires on, given the deadline's Local date.
  LocalDate fireDate(LocalDate deadlineLocalDate) =>
      deadlineLocalDate.addDays(-daysBefore);

  @override
  Map<String, Object?> toMap() => {
        'kind': 'calendar_day',
        'days_before': daysBefore,
        'local_time': localTime,
      };

  @override
  String get canonicalKey => 'calendar_day:$daysBefore:$localTime';
}

class RelativeMinutesReminder extends TaskReminder {
  const RelativeMinutesReminder({required this.minutesBefore});

  final int minutesBefore;

  /// Instant this reminder fires at, given the deadline Instant.
  DateTime fireInstant(DateTime deadline) =>
      deadline.subtract(Duration(minutes: minutesBefore));

  @override
  Map<String, Object?> toMap() => {
        'kind': 'relative_minutes',
        'minutes_before': minutesBefore,
      };

  @override
  String get canonicalKey => 'relative_minutes:$minutesBefore';
}
