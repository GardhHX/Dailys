import '../../core/db/database.dart';
import '../../core/time/local_date.dart';

/// One Habit row combined with the schedule/log context for the date the
/// list is being viewed on (design/screens/habit.md "Hari ini"/"Habit
/// lainnya" split; FR-5.2).
class HabitListItem {
  const HabitListItem({
    required this.habit,
    required this.scheduleToday,
    required this.logToday,
    required this.isTargetToday,
    required this.remainingIzinThisWeek,
  });

  final HabitRow habit;
  final HabitScheduleRow? scheduleToday;
  final HabitLogRow? logToday;

  /// Whether today is a target day under an *active* (non-paused) schedule —
  /// the only case the quick checklist applies to (FR-5.2).
  final bool isTargetToday;
  final int remainingIzinThisWeek;
}

class HabitState {
  const HabitState({
    this.loading = true,
    this.error,
    this.busy = false,
    this.items = const [],
    this.today,
  });

  final bool loading;
  final String? error;
  final bool busy;
  final List<HabitListItem> items;
  final LocalDate? today;

  HabitState copyWith({
    bool? loading,
    String? error,
    bool? busy,
    List<HabitListItem>? items,
    LocalDate? today,
  }) =>
      HabitState(
        loading: loading ?? this.loading,
        error: error,
        busy: busy ?? this.busy,
        items: items ?? this.items,
        today: today ?? this.today,
      );
}
