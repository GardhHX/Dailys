import '../../core/db/database.dart';

/// Splash startup stages (design/screens/splash.md "Tugas startup").
enum SplashStage { opening, newInstall, ready, failed }

/// Where Splash routes to once local readiness is confirmed
/// (design/screens/splash.md "Rute keluar").
enum SplashDestination { onboarding, home }

class SplashState {
  const SplashState._({
    required this.stage,
    this.destination,
    this.db,
    this.userId,
    this.deviceId,
    this.failureReasonKey,
    this.retriable = false,
  });

  const SplashState.opening() : this._(stage: SplashStage.opening);
  const SplashState.newInstall() : this._(stage: SplashStage.newInstall);

  const SplashState.ready({
    required SplashDestination destination,
    required AppDatabase db,
    required String userId,
    required String deviceId,
  }) : this._(
          stage: SplashStage.ready,
          destination: destination,
          db: db,
          userId: userId,
          deviceId: deviceId,
        );

  const SplashState.failed({required String reasonKey, required bool retriable})
      : this._(stage: SplashStage.failed, failureReasonKey: reasonKey, retriable: retriable);

  final SplashStage stage;
  final SplashDestination? destination;

  /// Populated once [stage] is [SplashStage.ready] — the local identity every
  /// downstream screen needs (M1-PLAN Section 7: identity is stable before any
  /// seed UUIDv5 is derived).
  final AppDatabase? db;
  final String? userId;
  final String? deviceId;

  /// ARB key for the failure message (design/screens/splash.md "Teks ID/EN").
  final String? failureReasonKey;

  /// Whether the failure state offers "Coba lagi" (design/screens/splash.md
  /// "Aksi dan pemulihan": retriable for e.g. locked DB, not for downgrade).
  final bool retriable;
}
