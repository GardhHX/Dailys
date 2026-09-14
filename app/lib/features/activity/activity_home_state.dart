import '../../core/db/database.dart';
import '../../core/projections/overlap.dart';
import '../../core/db/tables/enums.dart';
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
    this.now,
  });

  final LocalDate date;
  final List<ActivityRow> activities;
  final List<ActivityCategoryRow> categories;
  final double completionRatePercent;
  final List<OverlapWarning> overlaps;
  final bool loading;
  final String? error;
  final DateTime? now;

  List<ActivityRow> get followUps {
    final candidates = activities
        .where((a) =>
            !a.isDeleted &&
            a.source == ActivitySource.manual &&
            a.status == ActivityStatus.belum_mulai &&
            a.occurrenceDate == date.toYmd() &&
            (a.startTime == null ||
                a.isAllDay ||
                (now != null && (a.endTime ?? a.startTime!).isBefore(now!))))
        .toList();
    candidates.sort((a, b) {
      final rankA = a.isAllDay || a.startTime == null ? 0 : 1;
      final rankB = b.isAllDay || b.startTime == null ? 0 : 1;
      final byRank = rankA.compareTo(rankB);
      if (byRank != 0) return byRank;
      final byTime =
          (a.startTime ?? a.createdAt).compareTo(b.startTime ?? b.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return candidates.take(3).toList();
  }

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
    DateTime? now,
  }) =>
      ActivityHomeState(
        date: date ?? this.date,
        activities: activities ?? this.activities,
        categories: categories ?? this.categories,
        completionRatePercent:
            completionRatePercent ?? this.completionRatePercent,
        overlaps: overlaps ?? this.overlaps,
        loading: loading ?? this.loading,
        error: error,
        now: now ?? this.now,
      );
}
