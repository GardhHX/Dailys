import 'package:drift/drift.dart';

import 'converters.dart';
import 'enums.dart';
import 'global_columns.dart';

// ignore_for_file: recursive_getters
// (Drift references a column's own getter inside `.references(...)`; that is the
// documented pattern, not real recursion.)

/// M1 tables from schema.md. Deferred entities (Pomodoro, Timebox, Habit*,
/// Keuangan, WeeklyReview, and all Sync* tables) are intentionally absent; a
/// fresh M1 install creates exactly this subset (M1-PLAN Section 3, schema 22).

/// User (schema 3). Global columns without `origin_device_id`.
@DataClassName('UserRow')
class Users extends Table with TombstoneColumns {
  @override
  String get tableName => 'user';

  TextColumn get nama => text().withLength(min: 1)();
  TextColumn get email => text().nullable()();
  TextColumn get apiKeyHash => text().named('api_key_hash')();
}

/// UserSettings (schema 3.1). Exactly one synced row per user; id is the
/// deterministic UUIDv5 of `urn:dailys:v1.0:user-settings:{user_id}`.
@DataClassName('UserSettingsRow')
class UserSettings extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'user_settings';

  TextColumn get userId =>
      text().named('user_id').withLength(min: 36, max: 36).references(Users, #id)();
  TextColumn get language =>
      textEnum<Language>().withDefault(const Constant('id'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Jakarta'))();
  IntColumn get pomodoroFocusMinutes =>
      integer().named('pomodoro_focus_minutes').withDefault(const Constant(25))();
  IntColumn get pomodoroShortBreakMinutes =>
      integer().named('pomodoro_short_break_minutes').withDefault(const Constant(5))();
  IntColumn get pomodoroLongBreakMinutes =>
      integer().named('pomodoro_long_break_minutes').withDefault(const Constant(15))();
  IntColumn get pomodoroLongBreakInterval =>
      integer().named('pomodoro_long_break_interval').withDefault(const Constant(4))();
  TextColumn get alarmMode => textEnum<AlarmMode>().named('alarm_mode').withDefault(const Constant('sound'))();
  BoolColumn get notificationsEnabled =>
      boolean().named('notifications_enabled').withDefault(const Constant(true))();
  // Local time `HH:mm:ss`; day is fixed Sunday in v1.0 (schema 3.1).
  TextColumn get weeklyReviewTime =>
      text().named('weekly_review_time').withDefault(const Constant('09:00:00'))();

  @override
  List<String> get customConstraints => [
        'UNIQUE(user_id)',
        'CHECK (pomodoro_focus_minutes BETWEEN 1 AND 180)',
        'CHECK (pomodoro_short_break_minutes BETWEEN 1 AND 60)',
        'CHECK (pomodoro_long_break_minutes BETWEEN 1 AND 120)',
        'CHECK (pomodoro_long_break_interval BETWEEN 2 AND 12)',
      ];
}

/// DeviceSettings (schema 3.2). Local-only: no `server_revision`, no SyncChange,
/// never overwritten by a snapshot. `theme` is a per-device preference.
@DataClassName('DeviceSettingsRow')
class DeviceSettings extends Table {
  @override
  String get tableName => 'device_settings';

  // Same value as SyncDevice.id.
  TextColumn get deviceId => text().named('device_id').withLength(min: 36, max: 36)();
  TextColumn get notificationPermission => textEnum<NotificationPermission>()
      .named('notification_permission')
      .withDefault(const Constant('unknown'))();
  IntColumn get alarmVolumePercent =>
      integer().named('alarm_volume_percent').withDefault(const Constant(100))();
  TextColumn get theme => textEnum<ThemePreference>().withDefault(const Constant('system'))();
  IntColumn get activeTimerNotificationId =>
      integer().named('active_timer_notification_id').nullable()();
  TextColumn get lastPullCursor => text().named('last_pull_cursor').nullable()();
  TextColumn get syncGeneration =>
      text().named('sync_generation').withLength(min: 36, max: 36).nullable()();
  IntColumn get syncEpoch => integer().named('sync_epoch').nullable()();
  TextColumn get lastSyncStatus => textEnum<LastSyncStatus>()
      .named('last_sync_status')
      .withDefault(const Constant('idle'))();
  DateTimeColumn get lastSyncAt => dateTime().named('last_sync_at').nullable()();
  DateTimeColumn get onboardingCompletedAt =>
      dateTime().named('onboarding_completed_at').nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};

  @override
  List<String> get customConstraints =>
      ['CHECK (alarm_volume_percent BETWEEN 0 AND 100)'];
}

/// MataKuliah (schema 4).
@DataClassName('MataKuliahRow')
class MataKuliah extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'mata_kuliah';

  TextColumn get userId =>
      text().named('user_id').withLength(min: 36, max: 36).references(Users, #id)();
  TextColumn get nama => text().withLength(min: 1)();
  TextColumn get dosen => text().nullable()();
  IntColumn get sks => integer().nullable()();
  TextColumn get semester => text().nullable()();
  TextColumn get warna => text()(); // Hex #RRGGBB

  @override
  List<String> get customConstraints => ['CHECK (sks IS NULL OR sks > 0)'];
}

/// CourseNote (schema 4.1). Owned by MataKuliah; no second `user_id`.
@DataClassName('CourseNoteRow')
class CourseNote extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'course_note';

  TextColumn get mataKuliahId => text()
      .named('mata_kuliah_id')
      .withLength(min: 36, max: 36)
      .references(MataKuliah, #id)();
  // Local date `YYYY-MM-DD` chosen by the user in the user timezone.
  TextColumn get tanggal => text()();
  TextColumn get isi => text().withLength(min: 1)();
}

/// Tugas (schema 5).
@DataClassName('TugasRow')
class Tugas extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'tugas';

  TextColumn get userId =>
      text().named('user_id').withLength(min: 36, max: 36).references(Users, #id)();
  TextColumn get mataKuliahId => text()
      .named('mata_kuliah_id')
      .withLength(min: 36, max: 36)
      .nullable()
      .references(MataKuliah, #id)();
  TextColumn get judul => text().withLength(min: 1)();
  TextColumn get deskripsi => text().nullable()();
  DateTimeColumn get deadline => dateTime()(); // Instant
  TextColumn get prioritas => textEnum<TugasPrioritas>()();
  IntColumn get estimasiMenit => integer().named('estimasi_menit').nullable()();
  TextColumn get status => textEnum<TugasStatus>()();
  DateTimeColumn get completedAt => dateTime().named('completed_at').nullable()();
  DateTimeColumn get archivedAt => dateTime().named('archived_at').nullable()();
  // JSON array of typed TaskReminder objects (schema 5).
  TextColumn get reminders => text().map(const JsonMapListConverter())();

  @override
  List<String> get customConstraints => [
        'CHECK (estimasi_menit IS NULL OR estimasi_menit > 0)',
        // completed_at required iff status = selesai (schema 5).
        "CHECK ((status = 'selesai') = (completed_at IS NOT NULL))",
      ];
}

/// TugasChecklist (schema 5.1). Owned by Tugas; no `user_id`.
@DataClassName('TugasChecklistRow')
class TugasChecklist extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'tugas_checklist';

  TextColumn get tugasId =>
      text().named('tugas_id').withLength(min: 36, max: 36).references(Tugas, #id)();
  TextColumn get judul => text().withLength(min: 1)();
  BoolColumn get isDone => boolean().named('is_done').withDefault(const Constant(false))();
  IntColumn get urutan => integer()();

  @override
  List<String> get customConstraints => ['CHECK (urutan >= 0)'];
}

/// ActivityCategory (schema 6). Six deterministic UUIDv5 seeds per user plus
/// custom UUIDv4 categories.
@DataClassName('ActivityCategoryRow')
class ActivityCategory extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'activity_category';

  TextColumn get userId =>
      text().named('user_id').withLength(min: 36, max: 36).references(Users, #id)();
  TextColumn get nama => text().withLength(min: 1)();
  TextColumn get warna => text()(); // Hex #RRGGBB
  TextColumn get icon => text().nullable()();
  BoolColumn get isSystem => boolean().named('is_system').withDefault(const Constant(false))();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();
}

/// ActivityRecurrence (schema 7). Recurrence template; Activity holds occurrences.
@DataClassName('ActivityRecurrenceRow')
class ActivityRecurrence extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'activity_recurrence';

  TextColumn get userId =>
      text().named('user_id').withLength(min: 36, max: 36).references(Users, #id)();
  TextColumn get judul => text().withLength(min: 1)();
  TextColumn get activityCategoryId => text()
      .named('activity_category_id')
      .withLength(min: 36, max: 36)
      .references(ActivityCategory, #id)();
  // Local time `HH:mm:ss`; null for all-day.
  TextColumn get startTime => text().named('start_time').nullable()();
  TextColumn get endTime => text().named('end_time').nullable()();
  BoolColumn get isAllDay => boolean().named('is_all_day').withDefault(const Constant(false))();
  // Weekday integers 1..7, unique.
  TextColumn get recurringDays =>
      text().named('recurring_days').map(const IntListConverter())();
  TextColumn get startsOn => text().named('starts_on')(); // Local date
  TextColumn get endsOn => text().named('ends_on').nullable()(); // Local date
  TextColumn get reminderOffsetsMinutes => text()
      .named('reminder_offsets_minutes')
      .map(const IntListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get catatan => text().nullable()();
  // Server/local-service watermark; read-only via REST.
  TextColumn get materializedThroughDate =>
      text().named('materialized_through_date').nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK (end_time IS NULL OR start_time IS NULL OR end_time > start_time)',
        'CHECK (ends_on IS NULL OR ends_on >= starts_on)',
      ];
}

/// Activity (schema 8). One row = one occurrence or one non-recurring activity.
@DataClassName('ActivityRow')
class Activity extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'activity';

  TextColumn get userId =>
      text().named('user_id').withLength(min: 36, max: 36).references(Users, #id)();
  TextColumn get recurrenceId => text()
      .named('recurrence_id')
      .withLength(min: 36, max: 36)
      .nullable()
      .references(ActivityRecurrence, #id)();
  TextColumn get occurrenceDate => text().named('occurrence_date')(); // Local date
  TextColumn get judul => text().withLength(min: 1)();
  TextColumn get activityCategoryId => text()
      .named('activity_category_id')
      .withLength(min: 36, max: 36)
      .references(ActivityCategory, #id)();
  DateTimeColumn get startTime => dateTime().named('start_time').nullable()(); // Instant
  DateTimeColumn get endTime => dateTime().named('end_time').nullable()(); // Instant
  BoolColumn get isAllDay => boolean().named('is_all_day').withDefault(const Constant(false))();
  TextColumn get status => textEnum<ActivityStatus>()();
  TextColumn get source => textEnum<ActivitySource>()();
  TextColumn get sourceId =>
      text().named('source_id').withLength(min: 36, max: 36).nullable()();
  TextColumn get reminderOffsetsMinutes => text()
      .named('reminder_offsets_minutes')
      .map(const IntListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get catatan => text().nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK (end_time IS NULL OR start_time IS NULL OR end_time > start_time)',
      ];
}
