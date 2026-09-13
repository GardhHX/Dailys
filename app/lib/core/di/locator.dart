import 'package:get_it/get_it.dart';

/// App-wide service locator (M1-PLAN `core/di/locator.dart`).
///
/// Kept intentionally small: [SplashCubit] registers [AppDatabase] and derived
/// services (e.g. `MaterializationRunner`) once local readiness is confirmed,
/// so any screen reached after Splash can assume they are already registered.
final GetIt locator = GetIt.instance;
