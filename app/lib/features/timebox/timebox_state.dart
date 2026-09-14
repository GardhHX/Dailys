import '../../core/db/daos/timebox_dao.dart';
import '../../core/db/tables/enums.dart';
import '../../core/time/local_date.dart';

class TimeboxState {
  const TimeboxState({
    required this.weekStart,
    this.occurrences = const [],
    this.loading = true,
    this.error,
    this.now,
  });

  /// Monday of the visible week (local).
  final LocalDate weekStart;

  /// Active occurrences (joined with their schedule) across the visible week.
  final List<TimeboxOccurrence> occurrences;
  final bool loading;
  final String? error;

  /// Re-derived on a clock tick so missed-block detection stays live while
  /// the screen is open (mirrors `TugasListCubit`'s `now`).
  final DateTime? now;

  /// Still-`pending` occurrences whose planned end has already passed — the
  /// FR-3.7 missed-confirmation candidates.
  List<TimeboxOccurrence> missedCandidates(DateTime asOf) => occurrences
      .where((o) =>
          o.execution.status == TimeboxExecutionStatus.pending &&
          o.execution.plannedEndAt.isBefore(asOf))
      .toList();

  /// Occurrences for one local date (`YYYY-MM-DD`) that have not yet produced
  /// an Activity — i.e. still need to be shown as their own timeline/grid
  /// entry (a `completed` occurrence's Activity is the entry instead, so it
  /// is excluded here to avoid double-display, per design/screens/home.md
  /// "tidak menggandakan entry").
  List<TimeboxOccurrence> pendingForDate(String ymd) => occurrences
      .where((o) =>
          o.execution.occurrenceDate == ymd &&
          o.execution.status != TimeboxExecutionStatus.completed)
      .toList();

  TimeboxState copyWith({
    LocalDate? weekStart,
    List<TimeboxOccurrence>? occurrences,
    bool? loading,
    String? error,
    DateTime? now,
  }) =>
      TimeboxState(
        weekStart: weekStart ?? this.weekStart,
        occurrences: occurrences ?? this.occurrences,
        loading: loading ?? this.loading,
        error: error,
        now: now ?? this.now,
      );
}
