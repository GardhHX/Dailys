/// Domain enums for M1 tables.
///
/// Each enum member name is the canonical wire token from schema.md / openapi.yaml
/// and is stored verbatim (Drift `textEnum`). Do not rename members without
/// changing the contract and a migration.
library;

// Members are wire tokens (snake_case), stored verbatim by Drift `textEnum`.
// ignore_for_file: constant_identifier_names

/// UserSettings.language (schema 3.1).
enum Language { id, en }

/// UserSettings.alarm_mode (schema 3.1).
enum AlarmMode { sound, muted }

/// DeviceSettings.notification_permission (schema 3.2).
enum NotificationPermission { unknown, granted, denied }

/// DeviceSettings.theme (schema 3.2). Per-device, not synced.
enum ThemePreference { system, light, dark }

/// DeviceSettings.last_sync_status (schema 3.2).
enum LastSyncStatus {
  idle,
  syncing,
  success,
  failed,
  snapshot_required,
  review_required,
  recovery_required,
}

/// Tugas.prioritas (schema 5).
enum TugasPrioritas { low, medium, high }

/// Tugas.status (schema 5).
enum TugasStatus { belum, progress, selesai }

/// Activity.status (schema 8).
enum ActivityStatus { belum_mulai, selesai, dilewati }

/// Activity.source (schema 8).
enum ActivitySource { manual, pomodoro, timebox, habit }
