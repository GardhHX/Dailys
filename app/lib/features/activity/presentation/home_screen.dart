import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../timebox/application/timebox_providers.dart';
import '../../timebox/presentation/widgets/timebox_form_sheet.dart';
import '../../timebox/presentation/widgets/timebox_weekly_grid_view.dart';
import '../application/activity_providers.dart';
import '../data/activity_repository.dart';
import 'widgets/activity_form_sheet.dart';
import 'widgets/activity_list_view.dart';
import 'widgets/activity_timeline_view.dart';

/// Home — Daily Activity Log (FR-1.1 s/d FR-1.14) + Weekly Grid Timebox
/// (FR-3.3), digabung di 1 tab sesuai PRD Section 7. Layout & copy 1:1
/// dengan file desain Claude Design (eyebrow "HOME" + judul + subtitle,
/// toggle "Today View / Weekly Grid" jadi trailing header, tanpa AppBar
/// bawaan Flutter — mockup-nya sendiri tidak punya app-bar chrome).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewMode = ref.watch(homeViewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final viewMode = ref.watch(activityViewModeProvider);
    final activitiesAsync = ref.watch(activitiesForSelectedDateProvider);
    final completionAsync = ref.watch(completionRateProvider);
    final occurrences = activitiesAsync.valueOrNull ?? const [];
    final overlapping = overlappingOccurrenceKeys(occurrences);
    final dismissedDate = ref.watch(dismissedConflictDateProvider);
    // Banner konflik tampil di Today View & Weekly Grid (file desain
    // menunjukkan banner yang sama muncul di kedua sub-tab Home).
    final showConflictBanner =
        overlapping.isNotEmpty && dismissedDate != selectedDate;
    final isToday = homeViewMode == HomeViewMode.today;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            eyebrow: 'HOME',
            title: isToday ? 'Home' : 'Weekly Grid',
            subtitle: isToday
                ? 'Daily activity log, planned vs done'
                : 'Recurring timebox template, Mon–Sun',
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<HomeViewMode>(
                  segments: const [
                    ButtonSegment(
                      value: HomeViewMode.today,
                      icon: Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text('Today View'),
                    ),
                    ButtonSegment(
                      value: HomeViewMode.weeklyGrid,
                      icon: Icon(Icons.grid_view, size: 16),
                      label: Text('Weekly Grid'),
                    ),
                  ],
                  selected: {homeViewMode},
                  onSelectionChanged: (s) =>
                      ref.read(homeViewModeProvider.notifier).state = s.first,
                ),
                if (!isToday) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => showTimeboxFormSheet(
                      context,
                      weekStart: ref.read(selectedWeekStartProvider),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Block'),
                  ),
                ],
              ],
            ),
          ),
          if (showConflictBanner)
            _buildConflictBanner(
              context,
              ref,
              selectedDate,
              overlapping.length,
            ),
          if (isToday)
            Expanded(
              child: Column(
                children: [
                  _buildDateNav(context, ref, selectedDate, viewMode),
                  _buildStatCards(
                    context,
                    ref,
                    selectedDate,
                    completionAsync.valueOrNull,
                    occurrences.length,
                  ),
                  Expanded(
                    child: activitiesAsync.when(
                      data: (occ) {
                        return viewMode == ActivityViewMode.list
                            ? ActivityListView(
                                occurrences: occ,
                                onTapOccurrence: (o) =>
                                    _openEditor(context, ref, o, selectedDate),
                              )
                            : ActivityTimelineView(
                                occurrences: occ,
                                onTapOccurrence: (o) =>
                                    _openEditor(context, ref, o, selectedDate),
                              );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Failed to load: $e')),
                    ),
                  ),
                ],
              ),
            )
          else
            const Expanded(child: TimeboxWeeklyGridView()),
        ],
      ),
    );
  }

  /// Edit occurrence yang virtual berarti "lepas dari template" — dibuatkan
  /// row asli dulu (materialize) untuk hari itu saja, baru form edit dibuka
  /// untuk row barunya. Hari-hari lain tetap ikut template asli.
  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    ActivityOccurrence occurrence,
    DateTime selectedDate,
  ) async {
    var target = occurrence.data;
    if (occurrence.isVirtual) {
      final repo = ref.read(activityRepositoryProvider);
      final newId = await repo.materializeOccurrence(occurrence);
      final materialized = await repo.getById(newId);
      if (materialized == null) return;
      target = materialized;
    }
    if (!context.mounted) return;
    await showActivityFormSheet(
      context,
      editing: target,
      initialDate: selectedDate,
    );
  }

  Widget _buildDateNav(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    ActivityViewMode viewMode,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1)),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
            child: Text(
              _formatDate(selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedDateProvider.notifier).state =
                selectedDate.add(const Duration(days: 1)),
          ),
          const Spacer(),
          SegmentedButton<ActivityViewMode>(
            segments: const [
              ButtonSegment(
                value: ActivityViewMode.list,
                icon: Icon(Icons.view_list),
              ),
              ButtonSegment(
                value: ActivityViewMode.timeline,
                icon: Icon(Icons.view_timeline),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (s) =>
                ref.read(activityViewModeProvider.notifier).state = s.first,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            // Override minimumSize: theme default (`Size.fromHeight(48)`)
            // punya width infinite, dirancang untuk tombol full-width di
            // form (dibungkus `SizedBox(width: double.infinity)`). Dipakai
            // langsung di dalam `Row` tanpa override ini bikin layout crash
            // (`BoxConstraints(unconstrained)` — ditemukan saat verifikasi
            // run Windows, bukan cuma lewat flutter analyze).
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () =>
                showActivityFormSheet(context, initialDate: selectedDate),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Activity'),
          ),
        ],
      ),
    );
  }

  /// FR-1.8 — banner persisten kalau ada bentrok jadwal hari ini. Styling
  /// DIREVISI 23 Agu 2026 lewat getComputedStyle() pada
  /// `Dailys Desktop (standalone).html`: bg + border-nya solid ringan
  /// (`primaryContainer` + `primaryContainerBorder`), TAPI teks isi banner
  /// warna netral `onSurface` — cuma ikon segitiga yang pakai merah
  /// (`AppColors.warning`, beda dari `primary`) dan "Dismiss" yang pakai
  /// primary. Sebelumnya seluruh banner (ikon+teks) di-hardcode primary,
  /// itu salah.
  Widget _buildConflictBanner(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    int count,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = scheme.brightness;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primaryContainerBorderOf(brightness),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warningOf(brightness),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                count == 1
                    ? 'Ada 1 aktivitas yang bentrok jadwalnya hari ini.'
                    : 'Ada $count aktivitas yang bentrok jadwalnya hari ini.',
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentOnPrimaryContainerOf(
                  brightness,
                ),
              ),
              onPressed: () =>
                  ref.read(dismissedConflictDateProvider.notifier).state =
                      selectedDate,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    CompletionRate? completion,
    int scheduledToday,
  ) {
    final rate = completion?.rate ?? 0.0;
    final completed = completion?.completed ?? 0;
    final total = completion?.total ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      // `IntrinsicHeight` wajib di sini — `Row` dengan
      // `crossAxisAlignment.stretch` butuh tinggi terbatas dari parent
      // supaya bisa "stretch"-kan anaknya; tanpa ini, `Column` di atasnya
      // cuma kasih tinggi longgar (unbounded) ke Row, dan stretch menuntut
      // h=Infinity yang crash saat layout (ditemukan saat verifikasi run
      // Windows, bukan cuma lewat flutter analyze).
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatCard(
                label: 'COMPLETION',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(rate * 100).round()}%',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(value: rate, minHeight: 6),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completed of $total completed today',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'SCHEDULED TODAY',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scheduledToday',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Drag a card between columns to change its status',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => ref
                          .read(activityRepositoryProvider)
                          .bulkComplete(selectedDate),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Mark all done'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final target = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (target != null) {
                          await ref
                              .read(activityRepositoryProvider)
                              .bulkReschedule(selectedDate, target);
                        }
                      },
                      icon: const Icon(Icons.chevron_right, size: 18),
                      label: const Text('Reschedule unfinished'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format DIREVISI 23 Agu 2026 — screenshot "Add activity" & Home yang
  // dikirim user menunjukkan format "Today, Aug 22" (prefix "Today" kalau
  // tanggal terpilih = hari ini, bahasa Inggris) — bukan
  // "Senin, 22 Agu 2026" seperti draft sebelumnya. Format hari lain (bukan
  // hari ini) belum ada contoh eksplisit di file desain, dipakai pola yang
  // sama ("EEE, MMM d") supaya konsisten.
  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final label = isToday ? 'Today' : days[d.weekday - 1];
    return '$label, ${months[d.month - 1]} ${d.day}';
  }
}

/// Stat box abu-abu netral dengan eyebrow label merah. Eyebrow-nya
/// DIREVISI 23 Agu 2026: getComputedStyle() menunjukkan ukurannya lebih
/// kecil & lebih ringan (10px/w400/letterSpacing 1px) dibanding eyebrow
/// `ScreenHeader` (11px/w800/letterSpacing 1.1px, lihat `labelSmall` di
/// `app_theme.dart`) — 2 varian eyebrow yang beda skala, bukan 1 style yang
/// dipakai ulang begitu saja.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.archivo(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
