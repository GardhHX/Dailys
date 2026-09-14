import 'package:drift/drift.dart';

import 'converters.dart';
import 'enums.dart';
import 'global_columns.dart';
import 'm1_tables.dart';

// ignore_for_file: recursive_getters

/// M4 Habit tables from schema.md: Habit (11), HabitSchedule (11.1), HabitLog
/// (11.2). Keuangan (12-14.1) is a separate M4 slice/PR.

/// Habit (schema 11). `current_streak`/`longest_streak`/`is_archived` are
/// reconstructable caches derived from HabitSchedule + HabitLog (schema
/// 11.3), not the source of truth.
@DataClassName('HabitRow')
class Habit extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'habit';

  TextColumn get userId => text()
      .named('user_id')
      .withLength(min: 36, max: 36)
      .references(Users, #id)();
  TextColumn get nama => text().withLength(min: 1)();
  TextColumn get warna => text()(); // Hex #RRGGBB
  TextColumn get icon => text().nullable()();
  IntColumn get currentStreak =>
      integer().named('current_streak').withDefault(const Constant(0))();
  IntColumn get longestStreak =>
      integer().named('longest_streak').withDefault(const Constant(0))();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();
  IntColumn get urutan => integer()();

  @override
  List<String> get customConstraints => [
        'CHECK (current_streak >= 0)',
        'CHECK (longest_streak >= 0)',
        'CHECK (urutan >= 0)',
      ];
}

/// HabitSchedule (schema 11.1): versioned target-day/quota/state window.
/// Global columns without `user_id` (owner derived via `habit_id`).
@DataClassName('HabitScheduleRow')
class HabitSchedule extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'habit_schedule';

  TextColumn get habitId => text()
      .named('habit_id')
      .withLength(min: 36, max: 36)
      .references(Habit, #id)();
  // Local date `YYYY-MM-DD`, inclusive.
  TextColumn get effectiveFrom => text().named('effective_from')();
  // Local date `YYYY-MM-DD`, inclusive; null while this is the open-ended tail.
  TextColumn get effectiveTo => text().named('effective_to').nullable()();
  // Weekday integer 1..7, unique within the array.
  TextColumn get targetHari => text()
      .named('target_hari')
      .map(const IntListConverter())();
  IntColumn get maxIzinPerMinggu => integer()
      .named('max_izin_per_minggu')
      .withDefault(const Constant(1))();
  TextColumn get state => textEnum<HabitScheduleState>()();

  @override
  List<String> get customConstraints => [
        'CHECK (max_izin_per_minggu >= 0)',
        'CHECK (effective_to IS NULL OR effective_to >= effective_from)',
      ];
}

/// HabitLog (schema 11.2). Global columns without `user_id` (owner derived
/// via `habit_id`). Activity `source=habit` uses `HabitLog.id`, not
/// `Habit.id`, as `source_id`.
@DataClassName('HabitLogRow')
class HabitLog extends Table with TombstoneColumns, OriginColumn {
  @override
  String get tableName => 'habit_log';

  TextColumn get habitId => text()
      .named('habit_id')
      .withLength(min: 36, max: 36)
      .references(Habit, #id)();
  TextColumn get tanggal => text()(); // Local date `YYYY-MM-DD`
  TextColumn get status => textEnum<HabitLogStatus>()();
  TextColumn get catatan => text().nullable()();
}
