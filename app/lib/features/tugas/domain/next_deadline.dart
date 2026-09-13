import '../../../core/db/database.dart';
import '../../../core/db/tables/enums.dart';
import '../../../core/time/local_date.dart';
import 'tugas_history.dart';

/// Data behind Home's Next Deadline panel (design/screens/home.md; PRD
/// FR-6.6, FR-6.8–FR-6.10, FR-6.17). Presents existing Tugas data — not a new
/// scope: the nearest upcoming deadline among active tasks, and every overdue
/// active task (deadline passed, not yet `selesai`), which stays active
/// without a time limit (FR-6.17).
class NextDeadlineData {
  const NextDeadlineData({this.overdue = const [], this.upcoming});

  /// Overdue active tasks, earliest deadline (most overdue) first.
  final List<TugasRow> overdue;

  /// Nearest upcoming deadline among active, not-yet-overdue tasks, or null
  /// when none exist.
  final TugasRow? upcoming;

  bool get isEmpty => overdue.isEmpty && upcoming == null;
}

/// Computes [NextDeadlineData] from all of a user's non-deleted Tugas rows.
/// Completed tasks (`selesai`) never count as overdue or upcoming, even
/// inside their 7-day history grace window (schema 5).
NextDeadlineData computeNextDeadline({
  required List<TugasRow> allTugas,
  required TugasClassifier classifier,
  required LocalDate today,
  required DateTime now,
}) {
  final pending = allTugas.where(
    (t) => t.status != TugasStatus.selesai && classifier.isActive(t, today),
  );

  final overdue = pending.where((t) => t.deadline.isBefore(now)).toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));
  final upcoming = pending.where((t) => !t.deadline.isBefore(now)).toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));

  return NextDeadlineData(
    overdue: overdue,
    upcoming: upcoming.isEmpty ? null : upcoming.first,
  );
}

/// Whole-day distance from [today] to [deadlineLocalDate] (FR-6.8 "countdown
/// visual"), positive for future dates, negative for past ones.
int daysBetweenLocalDates(LocalDate today, LocalDate deadlineLocalDate) {
  final from = DateTime.utc(today.year, today.month, today.day);
  final to = DateTime.utc(
      deadlineLocalDate.year, deadlineLocalDate.month, deadlineLocalDate.day);
  return to.difference(from).inDays;
}
