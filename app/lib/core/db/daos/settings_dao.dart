import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/m1_tables.dart';

part 'settings_dao.g.dart';

/// UserSettings (synced) and DeviceSettings (local-only) access (schema 3.1/3.2).
@DriftAccessor(tables: [Users, UserSettings, DeviceSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<UserSettingsRow?> watchUserSettings(String userId) =>
      (select(userSettings)..where((t) => t.userId.equals(userId)))
          .watchSingleOrNull();

  Future<UserSettingsRow?> getUserSettings(String userId) =>
      (select(userSettings)..where((t) => t.userId.equals(userId)))
          .getSingleOrNull();

  /// Partial update of the synced settings row. Bumps `updated_at` because every
  /// mutation changes it (schema Section 2). REST `PUT /settings` is partial but
  /// stores/returns the full row; this mirrors that.
  Future<void> updateUserSettings(
    String userId,
    UserSettingsCompanion patch, {
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(userSettings)..where((t) => t.userId.equals(userId)))
        .write(patch.copyWith(updatedAt: Value(ts)));
  }

  Future<DeviceSettingsRow?> getDeviceSettings(String deviceId) =>
      (select(deviceSettings)..where((t) => t.deviceId.equals(deviceId)))
          .getSingleOrNull();

  /// Upserts the local-only device row. No `server_revision`/SyncChange — this
  /// never leaves the device (schema 3.2).
  Future<void> upsertDeviceSettings(DeviceSettingsCompanion row) =>
      into(deviceSettings).insertOnConflictUpdate(row);
}
