import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../data/activity_repository.dart';

enum ActivityViewMode { list, timeline }

/// Toggle level Home (bukan level Activity): Today View vs Weekly Grid
/// Timebox (PRD Section 7 — Home menggabungkan Activity + Timebox di 1 tab).
/// Ditaruh di sini karena `HomeScreen` sendiri sudah tinggal di
/// `features/activity/presentation` sejak Phase 1.
enum HomeViewMode { today, weeklyGrid }

final homeViewModeProvider = StateProvider<HomeViewMode>((ref) => HomeViewMode.today);

/// Tanggal terakhir user men-dismiss banner konflik jadwal — dibandingkan
/// terhadap [selectedDateProvider] (bukan flag boolean polos) supaya
/// otomatis muncul lagi begitu pindah ke tanggal lain, tanpa perlu logic
/// reset manual.
final dismissedConflictDateProvider = StateProvider<DateTime?>((ref) => null);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(ref.watch(databaseProvider).activityDao);
});

/// Tanggal yang lagi ditampilkan di Today View — default hari ini.
/// Navigasi mundur/maju (FR-1.14) tinggal ubah state ini.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final activityViewModeProvider = StateProvider<ActivityViewMode>((ref) => ActivityViewMode.list);

final activitiesForSelectedDateProvider = StreamProvider<List<ActivityOccurrence>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(activityRepositoryProvider).watchOccurrencesForDate(date);
});

final completionRateProvider = FutureProvider<CompletionRate>((ref) {
  // Bergantung pada activitiesForSelectedDateProvider supaya ke-refresh
  // otomatis tiap kali ada perubahan data hari itu.
  ref.watch(activitiesForSelectedDateProvider);
  final date = ref.watch(selectedDateProvider);
  return ref.watch(activityRepositoryProvider).completionRateForDate(date);
});
