import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activity/application/activity_providers.dart' show databaseProvider;
import '../data/timebox_repository.dart';

final timeboxRepositoryProvider = Provider<TimeboxRepository>((ref) {
  return TimeboxRepository(ref.watch(databaseProvider).timeboxDao);
});

/// Senin (weekday 1) dari minggu yang sedang ditampilkan di Weekly Grid.
/// Default: Senin minggu berjalan.
final selectedWeekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.subtract(Duration(days: today.weekday - 1));
});

final timeboxForWeekProvider = StreamProvider<List<TimeboxBlockOccurrence>>((ref) {
  final weekStart = ref.watch(selectedWeekStartProvider);
  return ref.watch(timeboxRepositoryProvider).watchForWeek(weekStart);
});
