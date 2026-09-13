import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/time/local_date.dart';
import '../../core/time/tz_data.dart';
import '../../l10n/app_localizations.dart';
import 'add_edit_tugas_sheet.dart';
import 'courses_screen.dart';
import 'tugas_detail_screen.dart';
import 'tugas_labels.dart';
import 'tugas_list_cubit.dart';
import 'tugas_list_state.dart';

/// Tugas tab (design/screens/tugas.md): Active / History / Courses tabs with
/// filter + sort on the active list and week-navigable history. The Panel Next
/// Deadline on Home (FR-6.6) is a separate surface and not part of this route.
class TugasListScreen extends StatefulWidget {
  const TugasListScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.deviceId,
  });

  final AppDatabase db;
  final String userId;
  final String deviceId;

  @override
  State<TugasListScreen> createState() => _TugasListScreenState();
}

class _TugasListScreenState extends State<TugasListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  TugasListCubit? _cubit;
  tz.Location? _location;

  @override
  void initState() {
    super.initState();
    _init();
    _tabController.addListener(() => setState(() {}));
  }

  Future<void> _init() async {
    ensureTimeZoneDatabaseLoaded();
    final settings = await widget.db.settingsDao.getUserSettings(widget.userId);
    final location = tz.getLocation(settings?.timezone ?? 'Asia/Jakarta');
    if (!mounted) return;
    setState(() {
      _location = location;
      _cubit = TugasListCubit(db: widget.db, userId: widget.userId, location: location);
    });
  }

  @override
  void dispose() {
    _cubit?.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = _cubit;
    if (cubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final onCoursesTab = _tabController.index == 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tugasTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.tugasTabActive),
            Tab(text: l10n.tugasTabHistory),
            Tab(text: l10n.tugasTabCourses),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (onCoursesTab) {
            showAddEditCourseSheet(context, db: widget.db, userId: widget.userId);
          } else {
            showAddEditTugasSheet(context, cubit: cubit);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActiveTab(cubit: cubit, onOpen: _openDetail),
          _HistoryTab(cubit: cubit, onOpen: _openDetail),
          CoursesTab(db: widget.db, userId: widget.userId),
        ],
      ),
    );
  }

  void _openDetail(String tugasId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TugasDetailScreen(
        db: widget.db,
        userId: widget.userId,
        location: _location!,
        tugasId: tugasId,
      ),
    ));
  }
}

class _ActiveTab extends StatelessWidget {
  const _ActiveTab({required this.cubit, required this.onOpen});
  final TugasListCubit cubit;
  final void Function(String tugasId) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TugasListCubit, TugasListState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = state.active;
        return Column(
          children: [
            _FilterSortBar(cubit: cubit, state: state, l10n: l10n),
            Expanded(
              child: tasks.isEmpty
                  ? Center(child: Text(
                      state.hasActiveFilter ? l10n.tugasEmptyFiltered : l10n.tugasEmpty))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: tasks.length,
                      itemBuilder: (context, i) => _TugasTile(
                        tugas: tasks[i],
                        state: state,
                        cubit: cubit,
                        l10n: l10n,
                        onOpen: onOpen,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.cubit, required this.onOpen});
  final TugasListCubit cubit;
  final void Function(String tugasId) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return BlocBuilder<TugasListCubit, TugasListState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups = state.historyGroups;
        final week = state.historyWeek;
        String fmt(LocalDate d) =>
            DateFormat.MMMd(locale).format(DateTime(d.year, d.month, d.day));
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: cubit.historyPreviousWeek,
                ),
                Tooltip(
                  message: l10n.tugasThisWeek,
                  child: TextButton(
                    onPressed: cubit.historyThisWeek,
                    child: Text(l10n.tugasWeekRange(fmt(week.monday), fmt(week.sunday))),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: cubit.historyNextWeek,
                ),
              ],
            ),
            Expanded(
              child: groups.isEmpty
                  ? Center(child: Text(l10n.tugasHistoryEmpty))
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        for (final g in groups) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: Text(
                              DateFormat.yMMMEd(locale)
                                  .format(DateTime(g.date.year, g.date.month, g.date.day)),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          for (final t in g.tugas)
                            _TugasTile(
                              tugas: t,
                              state: state,
                              cubit: cubit,
                              l10n: l10n,
                              onOpen: onOpen,
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterSortBar extends StatelessWidget {
  const _FilterSortBar({required this.cubit, required this.state, required this.l10n});
  final TugasListCubit cubit;
  final TugasListState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Text(l10n.tugasFilters, style: Theme.of(context).textTheme.labelLarge),
          ),
          PopupMenuButton<TugasSort>(
            initialValue: state.sort,
            onSelected: cubit.setSort,
            itemBuilder: (context) => [
              PopupMenuItem(value: TugasSort.deadline, child: Text(l10n.tugasSortDeadline)),
              PopupMenuItem(value: TugasSort.prioritas, child: Text(l10n.tugasSortPriority)),
              PopupMenuItem(value: TugasSort.course, child: Text(l10n.tugasSortCourse)),
            ],
            child: Chip(
              avatar: const Icon(Icons.sort, size: 18),
              label: Text('${l10n.tugasSort}: ${_sortLabel(state.sort)}'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<TugasStatus?>(
            onSelected: cubit.setStatusFilter,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.tugasFilterAll)),
              for (final s in TugasStatus.values)
                PopupMenuItem(value: s, child: Text(tugasStatusLabel(s, l10n))),
            ],
            child: Chip(
              label: Text(
                  '${l10n.tugasFilterStatus}: ${state.statusFilter == null ? l10n.tugasFilterAll : tugasStatusLabel(state.statusFilter!, l10n)}'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<TugasPrioritas?>(
            onSelected: cubit.setPriorityFilter,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.tugasFilterAll)),
              for (final p in TugasPrioritas.values)
                PopupMenuItem(value: p, child: Text(tugasPriorityLabel(p, l10n))),
            ],
            child: Chip(
              label: Text(
                  '${l10n.tugasFilterPriority}: ${state.priorityFilter == null ? l10n.tugasFilterAll : tugasPriorityLabel(state.priorityFilter!, l10n)}'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<String?>(
            onSelected: cubit.setCourseFilter,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.tugasFilterAll)),
              for (final c in state.courses)
                PopupMenuItem(value: c.id, child: Text(c.nama)),
            ],
            child: Chip(
              label: Text(
                  '${l10n.tugasFilterCourse}: ${state.courseFilter == null ? l10n.tugasFilterAll : (state.courseFor(state.courseFilter)?.nama ?? '')}'),
            ),
          ),
          if (state.hasActiveFilter) ...[
            const SizedBox(width: AppSpacing.sm),
            ActionChip(
              avatar: const Icon(Icons.clear, size: 18),
              label: Text(l10n.tugasClearFilters),
              onPressed: cubit.clearFilters,
            ),
          ],
        ],
      ),
    );
  }

  String _sortLabel(TugasSort sort) => switch (sort) {
        TugasSort.deadline => l10n.tugasSortDeadline,
        TugasSort.prioritas => l10n.tugasSortPriority,
        TugasSort.course => l10n.tugasSortCourse,
      };
}

class _TugasTile extends StatelessWidget {
  const _TugasTile({
    required this.tugas,
    required this.state,
    required this.cubit,
    required this.l10n,
    required this.onOpen,
  });

  final TugasRow tugas;
  final TugasListState state;
  final TugasListCubit cubit;
  final AppLocalizations l10n;
  final void Function(String tugasId) onOpen;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final course = state.courseFor(tugas.mataKuliahId);
    final overdue = state.isOverdue(tugas);
    final deadline = DateFormat.yMMMEd(locale).add_jm().format(tugas.deadline.toLocal());
    final done = tugas.status == TugasStatus.selesai;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: _PriorityDot(prioritas: tugas.prioritas),
        title: Text(
          tugas.judul,
          style: done ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$deadline · ${tugasStatusLabel(tugas.status, l10n)}'),
            Row(
              children: [
                if (course != null) ...[
                  Flexible(child: Text(course.nama, overflow: TextOverflow.ellipsis)),
                ],
                if (overdue) ...[
                  if (course != null) const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.tugasOverdue,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<_TileAction>(
          onSelected: (a) => _onAction(a),
          itemBuilder: (context) => [
            if (tugas.status != TugasStatus.selesai)
              PopupMenuItem(value: _TileAction.done, child: Text(l10n.tugasMarkDone)),
            if (tugas.status == TugasStatus.belum)
              PopupMenuItem(value: _TileAction.progress, child: Text(l10n.tugasMarkProgress)),
            if (tugas.status == TugasStatus.selesai)
              PopupMenuItem(value: _TileAction.reopen, child: Text(l10n.tugasReopen)),
            PopupMenuItem(
              value: _TileAction.archive,
              child: Text(tugas.archivedAt != null ? l10n.tugasUnarchive : l10n.tugasArchive),
            ),
          ],
        ),
        onTap: () => onOpen(tugas.id),
      ),
    );
  }

  void _onAction(_TileAction a) {
    switch (a) {
      case _TileAction.done:
        cubit.setStatus(tugas.id, TugasStatus.selesai);
      case _TileAction.progress:
        cubit.setStatus(tugas.id, TugasStatus.progress);
      case _TileAction.reopen:
        cubit.setStatus(tugas.id, TugasStatus.belum);
      case _TileAction.archive:
        cubit.setArchived(tugas.id, tugas.archivedAt == null);
    }
  }
}

enum _TileAction { done, progress, reopen, archive }

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.prioritas});
  final TugasPrioritas prioritas;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (prioritas) {
      TugasPrioritas.high => scheme.error,
      TugasPrioritas.medium => scheme.tertiary,
      TugasPrioritas.low => scheme.outline,
    };
    return CircleAvatar(backgroundColor: color, radius: 6);
  }
}
