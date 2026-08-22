import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/theme_mode_provider.dart';

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

const _navItems = [
  _NavItem(Icons.home_outlined, 'Home'),
  _NavItem(Icons.checklist_outlined, 'Tugas'),
  _NavItem(Icons.timer_outlined, 'Pomodoro'),
  _NavItem(Icons.account_balance_wallet_outlined, 'Keuangan'),
  _NavItem(Icons.local_fire_department_outlined, 'Habit'),
];

/// Sidebar desktop kustom — logo "Dailys" + nav item kapsul penuh + toggle
/// Dark mode + link Settings, 1:1 dengan layout file desain Claude Design
/// (bukan `NavigationRail` bawaan Material yang bentuknya beda — ikon di
/// atas label, dipusatkan, tanpa kapsul lebar).
class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      width: 220,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Dailys', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SidebarItem(
                      icon: _navItems[i].icon,
                      label: _navItems[i].label,
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  onTap: () => ref.read(themeModeProvider.notifier).state =
                      isDark ? ThemeMode.light : ThemeMode.dark,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isDark ? 'Light mode' : 'Dark mode',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  onTap: () => context.push('/settings'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Settings',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  // Styling DIREVISI 23 Agu 2026 lewat getComputedStyle() pada
  // `Dailys Desktop (standalone).html`: radius nav item aktif ternyata
  // 10px (bukan pill/capsule 999 seperti draft sebelumnya, meski
  // lebar item 206px — tetap rounded-rect, bukan kapsul penuh). Warna teks
  // "di atas fill primary" ternyata #F3F2F2 (sama dgn token `surfaceLight`,
  // bukan putih murni), dan ikon+teks item TIDAK aktif pakai `onSurface`
  // penuh (bukan `onSurfaceVariant`/muted seperti draft sebelumnya) —
  // font-weight juga beda: aktif 800, tidak aktif cuma 500.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onFill = AppColors.surfaceLight;
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.navPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.navPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? onFill : scheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? onFill : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
