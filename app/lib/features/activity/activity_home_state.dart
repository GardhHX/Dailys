import '../../core/db/database.dart';
import '../../core/projections/overlap.dart';
import '../../core/time/local_date.dart';

class ActivityHomeState {
  const ActivityHomeState({
    required this.date,
    this.activities = const [],
    this.categories = const [],
    this.completionRatePercent = 0,
    this.overlaps = const [],
    this.loading = true,
    this.error,
  });

  final LocalDate date;
  final List<ActivityRow> activities;
  final List<ActivityCategoryRow> categories;
  final double completionRatePercent;
  final List<OverlapWarning> overlaps;
  final bool loading;
  final String? error;

  /// Activities with a concrete Instant range (schema 8: "Home menampilkan
  /// timed activities dan bagian tanpa waktu terpisah" per design/screens/home.md).
  List<ActivityRow> get timed =>
      activities.where((a) => !a.isAllDay && a.startTime != null).toList()
        ..sort((a, b) => a.startTime!.compareTo(b.startTime!));

  /// All-day or flexible (no start time) activities.
  List<ActivityRow> get untimed =>
      activities.where((a) => a.isAllDay || a.startTime == null).toList()
        ..sort((a, b) => a.judul.compareTo(b.judul));

  ActivityHomeState copyWith({
    LocalDate? date,
    List<ActivityRow>? activities,
    List<ActivityCategoryRow>? categories,
    double? completionRatePercent,
    List<OverlapWarning>? overlaps,
    bool? loading,
    String? error,
  }) =>
      ActivityHomeState(
        date: date ?? this.date,
        activities: activities ?? this.activities,
        categories: categories ?? this.categories,
        completionRatePercent: completionRatePercent ?? this.completionRatePercent,
        overlaps: overlaps ?? this.overlaps,
        loading: loading ?? this.loading,
        error: error,
      );
}
