import 'package:drift/drift.dart';

import 'converters.dart';
import 'enums.dart';
import 'global_columns.dart';
import 'm1_tables.dart';

// ignore_for_file: recursive_getters

/// M3 tables from schema.md: TimeboxSchedule/TimeboxExecution (schema 10/10.1)
/// and PomodoroSession (schema 9). Deferred from M1-PLAN Section 3; added here
/// once the milestone starts (schema 22 "Instalasi baru M1 membuat subset ini;
/// migration menuju M2+ menambah sisanya").

/// PomodoroSession (schema 9).
@DataClassName('PomodoroSessionRow')
class PomodoroSession extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'pomodoro_session';

  TextColumn get userId => text()
      .named('user_id')
      .withLength(min: 36, max: 36)
      .references(Users, #id)();
  TextColumn get tugasId => text()
      .named('tugas_id')
      .withLength(min: 36, max: 36)
      .nullable()
      .references(Tugas, #id)();
  // Habit table doesn't exist until M4; kept as a plain nullable id column so
  // the FK can be wired in later without a shape change (schema 9).
  TextColumn get habitId =>
      text().named('habit_id').withLength(min: 36, max: 36).nullable()();
  DateTimeColumn get startTime => dateTime().named('start_time')(); // Instant
  DateTimeColumn get endTime =>
      dateTime().named('end_time').nullable()(); // Instant
  DateTimeColumn get pausedAt =>
      dateTime().named('paused_at').nullable()(); // Instant
  IntColumn get accumulatedPauseSeconds => integer()
      .named('accumulated_pause_seconds')
      .withDefault(const Constant(0))();
  IntColumn get durasiMenit => integer().named('durasi_menit')();
  IntColumn get actualSeconds => integer().named('actual_seconds').nullable()();
  TextColumn get jenis => textEnum<PomodoroJenis>()();
  TextColumn get status => textEnum<PomodoroStatus>()();

  @override
  List<String> get customConstraints => [
        'CHECK (tugas_id IS NULL OR habit_id IS NULL)',
        'CHECK (accumulated_pause_seconds >= 0)',
        'CHECK (durasi_menit > 0)',
        'CHECK (actual_seconds IS NULL OR actual_seconds >= 0)',
        // paused_at required iff status = paused.
        "CHECK ((status = 'paused') = (paused_at IS NOT NULL))",
        // end_time required for completed/cancelled (schema 9).
        "CHECK (status NOT IN ('completed', 'cancelled') OR end_time IS NOT NULL)",
      ];
}

/// TimeboxSchedule (schema 10): template/ad-hoc definition. Outcome per date
/// lives in [TimeboxExecution].
@DataClassName('TimeboxScheduleRow')
class TimeboxSchedule extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'timebox_schedule';

  TextColumn get userId => text()
      .named('user_id')
      .withLength(min: 36, max: 36)
      .references(Users, #id)();
  TextColumn get tugasId => text()
      .named('tugas_id')
      .withLength(min: 36, max: 36)
      .nullable()
      .references(Tugas, #id)();
  // Habit table doesn't exist until M4 (see PomodoroSession.habitId note).
  TextColumn get habitId =>
      text().named('habit_id').withLength(min: 36, max: 36).nullable()();
  TextColumn get judul => text().withLength(min: 1)();
  TextColumn get activityCategoryId => text()
      .named('activity_category_id')
      .withLength(min: 36, max: 36)
      .references(ActivityCategory, #id)();
  // Local time `HH:mm:ss`.
  TextColumn get startTime => text().named('start_time')();
  TextColumn get endTime => text().named('end_time')();
  // Weekday 1..7; required for recurring, absent for ad-hoc.
  IntColumn get hari => integer().nullable()();
  // Local date `YYYY-MM-DD`; required for ad-hoc, absent for recurring.
  TextColumn get tanggalSpesifik =>
      text().named('tanggal_spesifik').nullable()();
  BoolColumn get isRecurring => boolean().named('is_recurring')();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  TextColumn get reminderOffsetsMinutes => text()
      .named('reminder_offsets_minutes')
      .map(const IntListConverter())
      .withDefault(const Constant('[]'))();
  // Server/local-service watermark; read-only via REST.
  TextColumn get materializedThroughDate =>
      text().named('materialized_through_date').nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK (end_time > start_time)',
        'CHECK (tugas_id IS NULL OR habit_id IS NULL)',
        'CHECK (hari IS NULL OR hari BETWEEN 1 AND 7)',
        // Recurring requires `hari` and no `tanggal_spesifik`; ad-hoc the
        // opposite (schema 10).
        'CHECK ((is_recurring = 1 AND hari IS NOT NULL AND tanggal_spesifik IS NULL) '
            'OR (is_recurring = 0 AND hari IS NULL AND tanggal_spesifik IS NOT NULL))',
      ];
}

/// TimeboxExecution (schema 10.1): one materialized occurrence of a
/// TimeboxSchedule. Global columns without `user_id` (owner is derived via
/// `schedule_id`).
@DataClassName('TimeboxExecutionRow')
class TimeboxExecution extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'timebox_execution';

  TextColumn get scheduleId => text()
      .named('schedule_id')
      .withLength(min: 36, max: 36)
      .references(TimeboxSchedule, #id)();
  TextColumn get occurrenceDate =>
      text().named('occurrence_date')(); // Local date
  DateTimeColumn get plannedStartAt =>
      dateTime().named('planned_start_at')(); // Instant
  DateTimeColumn get plannedEndAt =>
      dateTime().named('planned_end_at')(); // Instant
  TextColumn get status => textEnum<TimeboxExecutionStatus>()();
  DateTimeColumn get actualStartAt =>
      dateTime().named('actual_start_at').nullable()(); // Instant
  DateTimeColumn get actualEndAt =>
      dateTime().named('actual_end_at').nullable()(); // Instant
  TextColumn get rescheduledToId => text()
      .named('rescheduled_to_id')
      .withLength(min: 36, max: 36)
      .nullable()
      .references(TimeboxExecution, #id)();
  TextColumn get activityId => text()
      .named('activity_id')
      .withLength(min: 36, max: 36)
      .nullable()
      .references(Activity, #id)();
  TextColumn get catatan => text().nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK (planned_end_at > planned_start_at)',
        // Completion mandates exactly one Activity (schema 10.1); every other
        // status carries none.
        "CHECK ((status = 'completed') = (activity_id IS NOT NULL))",
      ];
}
