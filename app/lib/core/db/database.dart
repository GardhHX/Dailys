import 'package:drift/drift.dart';

import 'daos/activity_dao.dart';
import 'daos/mata_kuliah_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/tugas_dao.dart';
import 'daos/pomodoro_dao.dart';
import '../ids/deterministic_id.dart';
import 'migrations.dart';
import 'seed/category_seed.dart';
import 'tables/converters.dart';
import 'tables/enums.dart';
import 'tables/m1_tables.dart';
import 'tables/m3_tables.dart';

part 'database.g.dart';

/// The local Drift database — offline source of truth for M1 (NFR-2).
///
/// Only the M1 subset of tables is created; deferred milestones add the rest via
/// future migrations (schema 22, M1-PLAN Section 3).
@DriftDatabase(
  tables: [
    Users,
    UserSettings,
    DeviceSettings,
    MataKuliah,
    CourseNote,
    Tugas,
    TugasChecklist,
    ActivityCategory,
    ActivityRecurrence,
    Activity,
    PomodoroSession,
    TimeboxSchedule,
    TimeboxExecution,
  ],
  daos: [SettingsDao, MataKuliahDao, TugasDao, ActivityDao, PomodoroDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  static const currentSchemaVersion = 2;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await createM1Indexes(m);
          await createM3Indexes(m);
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(pomodoroSession);
            await m.createTable(timeboxSchedule);
            await m.createTable(timeboxExecution);
            await createM3Indexes(m);
          }
        },
        beforeOpen: (details) async {
          // Soft-delete keeps rows, so FK enforcement is safe and wanted.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Provisions the local single-user identity: the User row, its deterministic
  /// UserSettings singleton, this device's DeviceSettings, and the six system
  /// ActivityCategory seeds. Idempotent — safe to call on every startup.
  ///
  /// [userId] and [deviceId] are the locally-provisioned identities that stay
  /// stable before any seed UUIDv5 is derived (M1-PLAN Section 7).
  Future<void> provisionLocalUser({
    required String userId,
    required String deviceId,
    required String nama,
    String? email,
    required String apiKeyHash,
    DateTime? now,
  }) async {
    final ts = (now ?? DateTime.now().toUtc());
    await transaction(() async {
      await into(users).insert(
        UsersCompanion.insert(
          id: userId,
          createdAt: ts,
          updatedAt: ts,
          nama: nama,
          email: Value(email),
          apiKeyHash: apiKeyHash,
        ),
        mode: InsertMode.insertOrIgnore,
      );

      await into(userSettings).insert(
        UserSettingsCompanion.insert(
          id: DeterministicId.userSettings(userId),
          createdAt: ts,
          updatedAt: ts,
          userId: userId,
        ),
        mode: InsertMode.insertOrIgnore,
      );

      await into(deviceSettings).insert(
        DeviceSettingsCompanion.insert(deviceId: deviceId),
        mode: InsertMode.insertOrIgnore,
      );

      await _ensureSeedCategories(userId: userId, deviceId: deviceId, ts: ts);
    });
  }

  /// Inserts any missing system ActivityCategory seeds for [userId]. Existing
  /// seeds are left untouched (id is the UUIDv5 natural key), so user renames or
  /// recolors survive re-provisioning.
  Future<void> ensureSeedCategories({
    required String userId,
    required String deviceId,
    DateTime? now,
  }) =>
      _ensureSeedCategories(
        userId: userId,
        deviceId: deviceId,
        ts: now ?? DateTime.now().toUtc(),
      );

  Future<void> _ensureSeedCategories({
    required String userId,
    required String deviceId,
    required DateTime ts,
  }) async {
    for (final seed in kSeedActivityCategories) {
      await into(activityCategory).insert(
        ActivityCategoryCompanion.insert(
          id: seed.idFor(userId),
          createdAt: ts,
          updatedAt: ts,
          userId: userId,
          nama: seed.nama,
          warna: seed.warna,
          icon: Value(seed.icon),
          isSystem: const Value(true),
          originDeviceId: Value(deviceId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}
