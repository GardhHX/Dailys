import 'package:go_router/go_router.dart';

import '../core/db/database.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/home_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/splash/splash_state.dart';

/// Local identity Splash resolves before routing anywhere — every screen past
/// Splash needs it (M1-PLAN Section 7).
class LocalSession {
  const LocalSession({required this.db, required this.userId, required this.deviceId});
  final AppDatabase db;
  final String userId;
  final String deviceId;
}

/// App-wide routes: Splash (`/`) is the only entry point; it hands off a
/// [LocalSession] via `extra` to Onboarding or Home. Only Splash and
/// Onboarding are first-run flows — Settings is pushed as a normal route from
/// Home, not part of this top-level shell.
GoRouter buildAppRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => SplashScreen(
            onReady: (destination, db, userId, deviceId) {
              final session = LocalSession(db: db, userId: userId, deviceId: deviceId);
              final path = destination == SplashDestination.onboarding ? '/onboarding' : '/home';
              GoRouter.of(context).go(path, extra: session);
            },
          ),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) {
            final session = state.extra! as LocalSession;
            return OnboardingScreen(
              db: session.db,
              userId: session.userId,
              deviceId: session.deviceId,
              onCompleted: () => GoRouter.of(context).go('/home', extra: session),
            );
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final session = state.extra! as LocalSession;
            return HomeShell(
              db: session.db,
              userId: session.userId,
              deviceId: session.deviceId,
            );
          },
        ),
      ],
    );
