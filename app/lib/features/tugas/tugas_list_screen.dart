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
import '../shell/tugas_shell.dart';
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

class _TugasListScreenState extends State<TugasListScreen> {
  int _tab = 0;
  bool _initFailed = false;
  TugasListCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    ensureTimeZoneDatabaseLoaded();
    try {
      final settings =
          await widget.db.settingsDao.getUserSettings(widget.userId);
      final location = tz.getLocation(settings?.timezone ?? 'Asia/Jakarta');
      if (!mounted) return;
      setState(() {
        _cubit = TugasListCubit(
            db: widget.db, userId: widget.userId, location: location);
      });
    } catch (_) {
      if (mounted) setState(() => _initFailed = true);
    }
  }

  @override
  void dispose() {
    _cubit?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = _cubit;
    if (cubit == null) {
      return Scaffold(
          body: Center(
              child: _initFailed
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(l10n.tugasLoadFailed),
                      TextButton(
                          onPressed: () {
                            setState(() => _initFailed = false);
                            _init();
                          },
                          child: Text(l10n.actionRetry))
                    ])
                  : const CircularProgressIndicator()));
    }
    final tabs = [
      l10n.tugasTabActive,
      l10n.tugasTabHistory,
      l10n.tugasTabCourses
    ];
    return TugasShell(
      db: widget.db,
      userId: widget.userId,
      deviceId: widget.deviceId,
      child: LayoutBuilder(builder: (context, constraints) {
        final mobile = MediaQuery.sizeOf(context).width <= 680;
        final wide = MediaQuery.sizeOf(context).width >= 1150;
        return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: mobile
                    ? 16
                    : wide
                        ? 38
                        : 26,
                vertical: mobile
                    ? 22
                    : wide
                        ? 32
                        : 28),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 16,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.tugasTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              const SizedBox(height: 8),
                              Text(l10n.tugasIntro,
                                  style: Theme.of(context).textTheme.bodySmall)
                            ]),
                        ElevatedButton.icon(
                            onPressed: () {
                              if (_tab == 2) {
                                showAddEditCourseSheet(context,
                                    db: widget.db, userId: widget.userId);
                              } else {
                                showAddEditTugasSheet(context, cubit: cubit);
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(_tab == 2
                                ? l10n.courseAddTitle
                                : l10n.tugasAddTitle)),
                      ]),
                  const SizedBox(height: 26),
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant))),
                      child: Wrap(spacing: 8, children: [
                        for (var i = 0; i < 3; i++)
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: _tab == i
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.transparent,
                                          width: 3))),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      shape: const RoundedRectangleBorder(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 12)),
                                  onPressed: () => setState(() => _tab = i),
                                  child: Text(tabs[i],
                                      style: TextStyle(
                                          fontSize: mobile ? 12 : 14,
                                          fontWeight: _tab == i
                                              ? FontWeight.w600
                                              : FontWeight.w400))))
                      ])),
                  const SizedBox(height: 24),
                  Expanded(
                      child: switch (_tab) {
                    0 => _ActiveTab(cubit: cubit, onOpen: _openDetail),
                    1 => _HistoryTab(cubit: cubit, onOpen: _openDetail),
                    _ => CoursesTab(
                        db: widget.db,
                        userId: widget.userId,
                        deviceId: widget.deviceId)
                  }),
                ]));
      }),
    );
  }

  void _openDetail(String tugasId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TugasDetailScreen(
        db: widget.db,
        tugasId: tugasId,
        listCubit: _cubit!,
        deviceId: widget.deviceId,
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
        if (state.failed) {
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.tugasLoadFailed),
            TextButton(onPressed: cubit.retry, child: Text(l10n.actionRetry))
          ]));
        }
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = state.active;
        return SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              _FilterSortBar(cubit: cubit, state: state, l10n: l10n),
              const SizedBox(height: 24),
              Text(l10n.tugasActiveCount(tasks.length),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(state.hasActiveFilter
                        ? l10n.tugasEmptyFiltered
                        : l10n.tugasEmpty))
              else
                LayoutBuilder(builder: (context, constraints) {
                  final columns =
                      MediaQuery.sizeOf(context).width > 680 ? 2 : 1;
                  return Wrap(spacing: 14, runSpacing: 14, children: [
                    for (final task in tasks)
                      SizedBox(
                          width: (constraints.maxWidth - (columns - 1) * 14) /
                              columns,
                          child: _TugasTile(
                              tugas: task,
                              state: state,
                              cubit: cubit,
                              l10n: l10n,
                              onOpen: onOpen))
                  ]);
                }),
            ]));
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
        if (state.failed) {
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.tugasLoadFailed),
            TextButton(onPressed: cubit.retry, child: Text(l10n.actionRetry))
          ]));
        }
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
                  tooltip: l10n.tugasPreviousWeek,
                  onPressed: cubit.historyPreviousWeek,
                ),
                Expanded(
                    child: TextButton(
                  onPressed: cubit.historyThisWeek,
                  child: Text(
                      l10n.tugasWeekRange(fmt(week.monday), fmt(week.sunday))),
                )),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.tugasNextWeek,
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
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm),
                            child: Text(
                              DateFormat.yMMMEd(locale).format(DateTime(
                                  g.date.year, g.date.month, g.date.day)),
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
  const _FilterSortBar(
      {required this.cubit, required this.state, required this.l10n});
  final TugasListCubit cubit;
  final TugasListState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Widget field<T>(String label, T value, List<DropdownMenuItem<T>> items,
              ValueChanged<T?> onChanged) =>
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 6),
            DropdownButtonFormField<T>(
                key: ValueKey('$label-$value'),
                initialValue: value,
                isExpanded: true,
                items: items,
                onChanged: onChanged,
                style: Theme.of(context).textTheme.bodyMedium)
          ]);
      final fields = <Widget>[
        field<String>(
            l10n.tugasFilterStatus,
            state.statusFilter?.name ?? 'all',
            [
              DropdownMenuItem(value: 'all', child: Text(l10n.tugasFilterAll)),
              for (final status in TugasStatus.values)
                DropdownMenuItem(
                    value: status.name,
                    child: Text(tugasStatusLabel(status, l10n)))
            ],
            (v) => cubit.setStatusFilter(
                v == 'all' ? null : TugasStatus.values.byName(v!))),
        field<String>(
            l10n.tugasFilterCourse,
            state.courseFilter ?? 'all',
            [
              DropdownMenuItem(value: 'all', child: Text(l10n.tugasFilterAll)),
              for (final course in state.courses)
                DropdownMenuItem(
                    value: course.id,
                    child: Text(course.nama, overflow: TextOverflow.ellipsis))
            ],
            (v) => cubit.setCourseFilter(v == 'all' ? null : v)),
        field<TugasSort>(l10n.tugasSort, state.sort, [
          for (final sort in TugasSort.values)
            DropdownMenuItem(value: sort, child: Text(_sortLabel(sort)))
        ], (v) {
          if (v != null) cubit.setSort(v);
        }),
      ];
      final columns = constraints.maxWidth < 440
          ? 1
          : constraints.maxWidth < 700
              ? 2
              : 3;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 12, runSpacing: 16, children: [
          for (final child in fields)
            SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 12) / columns,
                child: child)
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          PopupMenuButton<String>(
              tooltip: l10n.tugasFilterPriority,
              onSelected: (v) => cubit.setPriorityFilter(
                  v == 'all' ? null : TugasPrioritas.values.byName(v)),
              itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'all', child: Text(l10n.tugasFilterAll)),
                    for (final p in TugasPrioritas.values)
                      PopupMenuItem(
                          value: p.name,
                          child: Text(tugasPriorityLabel(p, l10n)))
                  ],
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                      '${l10n.tugasFilterPriority}: ${state.priorityFilter == null ? l10n.tugasFilterAll : tugasPriorityLabel(state.priorityFilter!, l10n)}'))),
          if (state.hasActiveFilter)
            TextButton(
                onPressed: cubit.clearFilters,
                child: Text(l10n.tugasClearFilters))
        ]),
      ]);
    });
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
    final deadline = DateFormat.MMMd(locale)
        .add_Hm()
        .format(tz.TZDateTime.from(tugas.deadline, state.location));
    final localDeadline = LocalDate.fromInstant(tugas.deadline, state.location);
    final days =
        DateTime(localDeadline.year, localDeadline.month, localDeadline.day)
            .difference(
                DateTime(state.today.year, state.today.month, state.today.day))
            .inDays;
    final countdown = overdue
        ? (days < 0 ? l10n.tugasDaysOverdue(-days) : l10n.tugasOverdue)
        : days == 0
            ? l10n.tugasDueToday
            : days == 1
                ? l10n.tugasDueTomorrow
                : l10n.tugasDaysRemaining(days);
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: overdue ? colors.errorContainer : colors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: BorderSide(
              color: overdue ? colors.error : colors.outlineVariant)),
      child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => onOpen(tugas.id),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(tugasStatusLabel(tugas.status, l10n),
                                  style: TextStyle(
                                      fontSize: 11, color: colors.primary))),
                          Text(
                              '${l10n.tugasFilterPriority} ${tugasPriorityLabel(tugas.prioritas, l10n).toLowerCase()}',
                              style: Theme.of(context).textTheme.labelSmall),
                        ]),
                    const SizedBox(height: 12),
                    Text(tugas.judul,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 18)),
                    if (tugas.deskripsi != null &&
                        tugas.deskripsi!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(tugas.deskripsi!,
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                    StreamBuilder<List<TugasChecklistRow>>(
                        stream: cubit.watchChecklist(tugas.id),
                        builder: (context, snapshot) {
                          final items =
                              snapshot.data ?? const <TugasChecklistRow>[];
                          return items.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                      l10n.tugasChecklistSummary(
                                          items.where((i) => i.isDone).length,
                                          items.length),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall));
                        }),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 13),
                    Text(countdown,
                        style: TextStyle(
                            color: overdue ? colors.error : colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text('$deadline · ${state.location.name}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 5),
                    Text(course?.nama ?? l10n.tugasNoCourse,
                        style: Theme.of(context).textTheme.bodySmall),
                  ]))),
    );
  }
}
