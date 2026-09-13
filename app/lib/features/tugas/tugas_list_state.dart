import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/time/local_date.dart';
import 'domain/tugas_history.dart';

/// Sort keys for the active list (design/screens/tugas.md: "sort deadline/
/// prioritas/course").
enum TugasSort { deadline, prioritas, course }

/// Tasks grouped under one `history_date` in the history view.
class TugasHistoryGroup {
  const TugasHistoryGroup(this.date, this.tugas);
  final LocalDate date;
  final List<TugasRow> tugas;
}

class TugasListState {
  const TugasListState({
    required this.location,
    required this.today,
    required this.now,
    required this.historyWeek,
    this.tugas = const [],
    this.courses = const [],
    this.statusFilter,
    this.priorityFilter,
    this.courseFilter,
    this.sort = TugasSort.deadline,
    this.loading = true,
  });

  final tz.Location location;
  final LocalDate today;
  final DateTime now;
  final WeekRange historyWeek;
  final List<TugasRow> tugas;
  final List<MataKuliahRow> courses;
  final TugasStatus? statusFilter;
  final TugasPrioritas? priorityFilter;
  final String? courseFilter;
  final TugasSort sort;
  final bool loading;

  static const _priorityRank = {
    TugasPrioritas.high: 0,
    TugasPrioritas.medium: 1,
    TugasPrioritas.low: 2,
  };

  TugasClassifier get classifier => TugasClassifier(location);

  MataKuliahRow? courseFor(String? id) {
    if (id == null) return null;
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  bool _passesFilters(TugasRow t) {
    if (statusFilter != null && t.status != statusFilter) return false;
    if (priorityFilter != null && t.prioritas != priorityFilter) return false;
    if (courseFilter != null && t.mataKuliahId != courseFilter) return false;
    return true;
  }

  int _compare(TugasRow a, TugasRow b) {
    switch (sort) {
      case TugasSort.deadline:
        return a.deadline.compareTo(b.deadline);
      case TugasSort.prioritas:
        final r = _priorityRank[a.prioritas]!.compareTo(_priorityRank[b.prioritas]!);
        return r != 0 ? r : a.deadline.compareTo(b.deadline);
      case TugasSort.course:
        final an = courseFor(a.mataKuliahId)?.nama ?? '';
        final bn = courseFor(b.mataKuliahId)?.nama ?? '';
        final r = an.toLowerCase().compareTo(bn.toLowerCase());
        return r != 0 ? r : a.deadline.compareTo(b.deadline);
    }
  }

  /// Active tasks (schema 5 classification) after filter + sort.
  List<TugasRow> get active {
    final c = classifier;
    return tugas.where((t) => c.isActive(t, today)).where(_passesFilters).toList()
      ..sort(_compare);
  }

  bool get hasActiveFilter =>
      statusFilter != null || priorityFilter != null || courseFilter != null;

  /// History tasks whose `history_date` falls inside [historyWeek], grouped by
  /// that date, most-recent day first.
  List<TugasHistoryGroup> get historyGroups {
    final c = classifier;
    final byDate = <LocalDate, List<TugasRow>>{};
    for (final t in tugas) {
      if (c.isActive(t, today)) continue;
      final d = c.historyDate(t);
      if (!historyWeek.contains(d)) continue;
      (byDate[d] ??= []).add(t);
    }
    final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final d in dates)
        TugasHistoryGroup(
          d,
          byDate[d]!..sort((a, b) => a.deadline.compareTo(b.deadline)),
        ),
    ];
  }

  bool isOverdue(TugasRow t) => classifier.isOverdue(t, now);

  TugasListState copyWith({
    LocalDate? today,
    DateTime? now,
    WeekRange? historyWeek,
    List<TugasRow>? tugas,
    List<MataKuliahRow>? courses,
    TugasStatus? statusFilter,
    bool clearStatusFilter = false,
    TugasPrioritas? priorityFilter,
    bool clearPriorityFilter = false,
    String? courseFilter,
    bool clearCourseFilter = false,
    TugasSort? sort,
    bool? loading,
  }) =>
      TugasListState(
        location: location,
        today: today ?? this.today,
        now: now ?? this.now,
        historyWeek: historyWeek ?? this.historyWeek,
        tugas: tugas ?? this.tugas,
        courses: courses ?? this.courses,
        statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
        priorityFilter:
            clearPriorityFilter ? null : (priorityFilter ?? this.priorityFilter),
        courseFilter: clearCourseFilter ? null : (courseFilter ?? this.courseFilter),
        sort: sort ?? this.sort,
        loading: loading ?? this.loading,
      );
}
