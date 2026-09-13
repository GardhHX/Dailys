import 'package:timezone/timezone.dart' as tz;

import '../../../core/db/database.dart';
import '../../../core/db/tables/enums.dart';
import '../../../core/time/local_date.dart';

/// Active vs. history classification for Tugas (schema 5), computed on read
/// without mutating the row ("Query tampilan menghitung history_date tanpa
/// memutasi row").
///
/// Rules (schema 5):
/// - A manually archived task (`archived_at != null`) is history immediately;
///   its `history_date` is the Local date of `archived_at`.
/// - A completed task auto-enters history at 00:00 of the seventh Local date
///   after `completed_at`'s Local date; its `history_date` is that date
///   (completed Local date + 7).
/// - Everything else — including overdue-but-unfinished tasks — stays active.
class TugasClassifier {
  const TugasClassifier(this.location);

  final tz.Location location;

  /// The Local date at which a completed task auto-archives, or null when the
  /// task has no `completed_at`.
  LocalDate? autoArchiveDate(TugasRow row) {
    final completedAt = row.completedAt;
    if (completedAt == null) return null;
    return LocalDate.fromInstant(completedAt, location).addDays(7);
  }

  /// Whether [row] belongs in the active list as of [today] (user-tz Local
  /// date). See class docs for the rule.
  bool isActive(TugasRow row, LocalDate today) {
    if (row.archivedAt != null) return false;
    final auto = autoArchiveDate(row);
    if (auto == null) return true; // not completed → active
    return today.isBefore(auto); // completed but grace window not elapsed
  }

  /// The `history_date` used to group a task in the history view. Only
  /// meaningful for tasks where [isActive] is false.
  LocalDate historyDate(TugasRow row) {
    final archivedAt = row.archivedAt;
    if (archivedAt != null) return LocalDate.fromInstant(archivedAt, location);
    // Auto-archived completed task; autoArchiveDate is non-null here.
    return autoArchiveDate(row)!;
  }

  /// Whether [row] is overdue: deadline passed and not yet completed. Overdue
  /// tasks stay active (schema 5) but are surfaced with an overdue badge.
  bool isOverdue(TugasRow row, DateTime now) =>
      row.status != TugasStatus.selesai && row.deadline.isBefore(now);
}

/// Monday–Sunday week window for the history navigator (design/screens/tugas.md:
/// "rentang Senin–Minggu yang bisa dinavigasi").
class WeekRange {
  const WeekRange(this.monday);

  /// Monday (ISO weekday 1) of the week [date] falls in.
  factory WeekRange.of(LocalDate date) =>
      WeekRange(date.addDays(-(date.weekday - 1)));

  final LocalDate monday;

  LocalDate get sunday => monday.addDays(6);

  bool contains(LocalDate date) =>
      !date.isBefore(monday) && !date.isAfter(sunday);

  WeekRange get previous => WeekRange(monday.addDays(-7));
  WeekRange get next => WeekRange(monday.addDays(7));

  @override
  bool operator ==(Object other) => other is WeekRange && other.monday == monday;

  @override
  int get hashCode => monday.hashCode;
}
