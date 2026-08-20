import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/home_screen.dart';
import '../../features/finance/presentation/keuangan_screen.dart';
import '../../features/habit/presentation/habit_screen.dart';
import '../../features/pomodoro/presentation/pomodoro_screen.dart';
import '../../features/task/presentation/tugas_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => _AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/tugas', builder: (context, state) => const TugasScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/pomodoro', builder: (context, state) => const PomodoroScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/keuangan', builder: (context, state) => const KeuanganScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/habit', builder: (context, state) => const HabitScreen()),
        ]),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      child: navigationShell,
    );
  }
}
