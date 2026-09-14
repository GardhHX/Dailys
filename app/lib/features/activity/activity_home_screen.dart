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
import '../settings/settings_screen.dart';
import '../tugas/tugas_list_screen.dart';
import 'activity_home_cubit.dart';
import 'activity_home_state.dart';
import 'add_activity_sheet.dart';

class ActivityHomeScreen extends StatefulWidget {
  const ActivityHomeScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.deviceId,
  });

  final AppDatabase db;
  final String userId;
  final String deviceId;

  @override
  State<ActivityHomeScreen> createState() => _ActivityHomeScreenState();
}

/// Home schedule view modes (design/preview/home.html toolbar: Daftar /
/// Timeline / Minggu).
enum _ScheduleMode { list, timeline, week }

class _ActivityHomeScreenState extends State<ActivityHomeScreen> {
  ActivityHomeCubit? _cubit;
  _ScheduleMode _mode = _ScheduleMode.timeline;
  String? _initError;
  late Stream<List<TugasRow>> _deadlines;

  @override
  void initState() {
    super.initState();
    _deadlines = widget.db.tugasDao.watchActiveTugas(widget.userId);
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
        _cubit = ActivityHomeCubit(
            db: widget.db, userId: widget.userId, location: location);
      });
    } catch (_) {
      if (mounted) setState(() => _initError = "load");
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
              child: _initError == null
                  ? const CircularProgressIndicator()
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(l10n.homeReadFailed),
                      TextButton(
                          onPressed: () {
                            setState(() => _initError = null);
                            _init();
                          },
                          child: Text(l10n.actionRetry)),
                    ])));
    }
    final locale = Localizations.localeOf(context).toString();
    return BlocBuilder<ActivityHomeCubit, ActivityHomeState>(
      bloc: cubit,
      builder: (context, state) =>
          LayoutBuilder(builder: (context, constraints) {
        final mobile = constraints.maxWidth <= 680;
        final compact = constraints.maxWidth <= 860;
        final colors = Theme.of(context).colorScheme;
        final activeDate =
            DateTime(state.date.year, state.date.month, state.date.day);
        final monday =
            activeDate.subtract(Duration(days: activeDate.weekday - 1));
        final navigation = [
          (Icons.home_filled, l10n.homeTitle),
          (Icons.article, l10n.navTasks),
          (Icons.timer, 'Pomodoro'),
          (Icons.account_balance_wallet, l10n.navFinance),
          (Icons.check_box, l10n.navHabit),
        ];
        Widget navItem(int i) => Tooltip(
              message: i <= 1 ? navigation[i].$2 : l10n.featureUnavailable,
              child: TextButton(
                onPressed: i == 0
                    ? cubit.goToToday
                    : i == 1
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => TugasListScreen(
                                db: widget.db,
                                userId: widget.userId,
                                deviceId: widget.deviceId)))
                        : null,
                style: TextButton.styleFrom(
                  backgroundColor:
                      i == 0 ? colors.primaryContainer : Colors.transparent,
                  foregroundColor: colors.primary,
                  padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 2 : 12, vertical: 12),
                ),
                child: mobile || compact
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(navigation[i].$1, size: 20),
                        if (mobile)
                          Text(navigation[i].$2,
                              style: const TextStyle(fontSize: 11))
                      ])
                    : Row(children: [
                        Icon(navigation[i].$1, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(navigation[i].$2))
                      ]),
              ),
            );
        final schedule =
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                SegmentedButton<_ScheduleMode>(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? colors.onSurface
                                : colors.surface),
                        foregroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? colors.surface
                                : colors.onSurface)),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                          value: _ScheduleMode.list, label: Text(l10n.homeList)),
                      ButtonSegment(
                          value: _ScheduleMode.timeline,
                          label: Text(l10n.homeTimeline)),
                      ButtonSegment(
                          value: _ScheduleMode.week, label: Text(l10n.homeWeek)),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (v) =>
                        setState(() => _mode = v.first)),
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  IconButton(
                      tooltip: l10n.previousDay,
                      onPressed: cubit.goToPreviousDay,
                      icon: const Icon(Icons.chevron_left)),
                  TextButton(
                      onPressed: () => _pickDate(context, state.date),
                      child: Text(DateFormat.yMd(locale).format(activeDate))),
                  IconButton(
                      tooltip: l10n.nextDay,
                      onPressed: cubit.goToNextDay,
                      icon: const Icon(Icons.chevron_right)),
                ]),
              ]),
          const SizedBox(height: 16),
          Row(
              children: List.generate(7, (i) {
            final day = monday.add(Duration(days: i));
            final selected =
                day.day == activeDate.day && day.month == activeDate.month;
            return Expanded(
                child: Padding(
                    padding: EdgeInsets.only(right: i == 6 ? 0 : 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor:
                              selected ? colors.primary : colors.surface,
                          foregroundColor:
                              selected ? colors.onPrimary : colors.onSurface,
                          side: BorderSide(
                              color: selected
                                  ? colors.primary
                                  : colors.outlineVariant)),
                      onPressed: () => cubit
                          .goToDate(LocalDate(day.year, day.month, day.day)),
                      child: Column(children: [
                        Text(DateFormat.E(locale).format(day),
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('${day.day}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600))
                      ]),
                    )));
          })),
          const SizedBox(height: 24),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: Text(l10n.homeSchedule,
                    style: Theme.of(context).textTheme.titleMedium)),
            if (_mode == _ScheduleMode.week)
              Text(
                  '${DateFormat.MMMd(locale).format(monday)} – ${DateFormat.MMMd(locale).format(monday.add(const Duration(days: 6)))}',
                  style: Theme.of(context).textTheme.bodySmall)
            else
              _CompletionBadge(state: state, l10n: l10n),
          ]),
          const SizedBox(height: 16),
          if (_mode == _ScheduleMode.week)
            _WeekGrid(
                monday: monday,
                cubit: cubit,
                state: state,
                deadlines: _deadlines,
                l10n: l10n,
                locale: locale,
                mobile: mobile,
                onActivityTap: (a) =>
                    _showActivityActions(context, a, cubit, l10n))
          else if (state.loading)
            const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()))
          else if (state.error != null)
            Column(children: [
              Text(l10n.homeReadFailed),
              TextButton(onPressed: cubit.retry, child: Text(l10n.actionRetry))
            ])
          else ...[
            if (state.overlaps.isNotEmpty)
              _OverlapBanner(count: state.overlaps.length, l10n: l10n),
            if (state.activities.isEmpty)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        Text(l10n.activityEmpty, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(l10n.homeEmptyHint,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton.icon(
                            onPressed: () =>
                                showAddActivitySheet(context, cubit: cubit),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.homeAdd)),
                      ]))),
            ..._buildAgenda(context, state, cubit, l10n, mobile),
          ],
        ]);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: colors.surface,
            toolbarHeight: 68,
            shape: Border(bottom: BorderSide(color: colors.outlineVariant)),
            title: Text(l10n.appWordmark,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1)),
            actions: [
              IconButton(
                  tooltip: l10n.activityToday,
                  onPressed: cubit.goToToday,
                  icon: const Icon(Icons.today_outlined)),
              TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                          db: widget.db,
                          userId: widget.userId,
                          deviceId: widget.deviceId))),
                  child: Text(l10n.settingsTitle)),
              const SizedBox(width: 16)
            ],
          ),
          bottomNavigationBar: mobile
              ? SafeArea(
                  child: Container(
                      decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border(
                              top: BorderSide(color: colors.outlineVariant))),
                      child: Row(
                          children: List.generate(
                              5, (i) => Expanded(child: navItem(i))))))
              : null,
          body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!mobile)
              Container(
                  width: compact ? 76 : 142,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(color: colors.outlineVariant))),
                  child: Column(children: [
                    for (var i = 0; i < 5; i++) ...[
                      navItem(i),
                      const SizedBox(height: 8)
                    ]
                  ])),
            Expanded(
                child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: mobile ? 16 : 28,
                        vertical: mobile ? 22 : 28),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.homeTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium),
                                      const SizedBox(height: 6),
                                      Text(
                                          '${DateFormat.yMMMMEEEEd(locale).format(activeDate)} · ${cubit.timezone}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall)
                                    ]),
                                ElevatedButton.icon(
                                    onPressed: () => showAddActivitySheet(
                                        context,
                                        cubit: cubit),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: Text(l10n.homeAdd)),
                              ]),
                          const SizedBox(height: 28),
                          if (constraints.maxWidth > 1000)
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: schedule),
                                  const SizedBox(width: 32),
                                  SizedBox(
                                      width: constraints.maxWidth > 1280
                                          ? 258
                                          : 210,
                                      child: _sidebar(context, cubit, l10n)),
                                ])
                          else ...[
                            schedule,
                            const SizedBox(height: 28),
                            _sidebar(context, cubit, l10n)
                          ],
                        ]))),
          ]),
        );
      }),
    );
  }

  /// Builds the day's agenda body: timed entries (Timeline puts the start time
  /// in a left gutter), the "no specific time" flexible section, and deadline
  /// overlays for tasks due on the active date — mirroring design/preview/home.html.
  List<Widget> _buildAgenda(BuildContext context, ActivityHomeState state,
      ActivityHomeCubit cubit, AppLocalizations l10n, bool mobile) {
    if (state.activities.isEmpty) return const [];
    final widgets = <Widget>[];
    // The first not-started Timebox becomes the highlighted "feature" card.
    ActivityRow? feature;
    for (final a in state.timed) {
      if (a.source == ActivitySource.timebox &&
          a.status == ActivityStatus.belum_mulai) {
        feature = a;
        break;
      }
    }
    for (final activity in state.timed) {
      final entry = _AgendaEntry(
          activity: activity,
          state: state,
          cubit: cubit,
          l10n: l10n,
          feature: identical(activity, feature),
          onTap: () => _showActivityActions(context, activity, cubit, l10n));
      if (_mode == _ScheduleMode.timeline && !mobile) {
        widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 48,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: Text(cubit.formatTime(activity.startTime!),
                          style: Theme.of(context).textTheme.bodySmall))),
              const SizedBox(width: 12),
              Expanded(child: entry),
            ])));
      } else {
        widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: entry));
      }
    }
    if (state.untimed.isNotEmpty) {
      widgets.add(const SizedBox(height: AppSpacing.xxlx));
      widgets.add(const Divider());
      widgets.add(_SectionHeader(title: l10n.activityUnscheduledSection));
      for (final activity in state.untimed) {
        widgets.add(_FlexRow(
            activity: activity,
            state: state,
            cubit: cubit,
            l10n: l10n,
            onTap: () => _showActivityActions(context, activity, cubit, l10n)));
      }
    }
    return widgets;
  }

  void _showActivityActions(BuildContext context, ActivityRow activity,
      ActivityHomeCubit cubit, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(activity.judul,
                      style: Theme.of(context).textTheme.titleSmall))),
          if (activity.status != ActivityStatus.selesai)
            ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.activityMarkDone),
                onTap: () {
                  cubit.setStatus(activity.id, ActivityStatus.selesai);
                  Navigator.pop(sheetContext);
                }),
          if (activity.status != ActivityStatus.dilewati)
            ListTile(
                leading: const Icon(Icons.skip_next_outlined),
                title: Text(l10n.activityMarkSkipped),
                onTap: () {
                  cubit.setStatus(activity.id, ActivityStatus.dilewati);
                  Navigator.pop(sheetContext);
                }),
          if (activity.status != ActivityStatus.belum_mulai)
            ListTile(
                leading: const Icon(Icons.restart_alt),
                title: Text(l10n.activityReopen),
                onTap: () {
                  cubit.setStatus(activity.id, ActivityStatus.belum_mulai);
                  Navigator.pop(sheetContext);
                }),
          ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.activityDelete),
              onTap: () {
                cubit.deleteActivity(activity.id);
                Navigator.pop(sheetContext);
              }),
        ]),
      ),
    );
  }

  Widget _sidebar(
      BuildContext context, ActivityHomeCubit cubit, AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _deadlinePanel(context, cubit, l10n),
      const SizedBox(height: AppSpacing.xxxl),
      _WeeklyReviewSection(l10n: l10n),
    ]);
  }

  Widget _deadlinePanel(
      BuildContext context, ActivityHomeCubit cubit, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
            child: Text(l10n.homeDeadlines,
                style: Theme.of(context).textTheme.titleMedium)),
        Text(l10n.tugasTabActive,
            style: Theme.of(context).textTheme.bodySmall),
      ]),
      const SizedBox(height: 16),
      StreamBuilder<List<TugasRow>>(
          stream: _deadlines,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(children: [
                Text(l10n.homeDeadlineFailed),
                TextButton(
                    onPressed: () => setState(() => _deadlines =
                        widget.db.tugasDao.watchActiveTugas(widget.userId)),
                    child: Text(l10n.actionRetry))
              ]);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final tasks = snapshot.data!
                .where((t) =>
                    t.status != TugasStatus.selesai && t.archivedAt == null)
                .toList()
              ..sort((a, b) => a.deadline.compareTo(b.deadline));
            if (tasks.isEmpty) {
              return Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.homeNoDeadlines,
                          style: Theme.of(context).textTheme.bodySmall)));
            }
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final task in tasks.take(3))
                    _DeadlineCard(
                        task: task, cubit: cubit, l10n: l10n, locale: locale),
                ]);
          }),
    ]);
  }

  Future<void> _pickDate(BuildContext context, LocalDate current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, current.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _cubit?.goToDate(LocalDate(picked.year, picked.month, picked.day));
    }
  }
}

/// Maps an [ActivitySource] to the entry type label shown in the category chip
/// (design/preview/home.html: "Kategori · Timebox|Habit|Aktivitas").
String _typeLabel(ActivitySource source, AppLocalizations l10n) {
  switch (source) {
    case ActivitySource.timebox:
      return l10n.activityTypeTimebox;
    case ActivitySource.habit:
      return l10n.activityTypeHabit;
    case ActivitySource.pomodoro:
      return l10n.activityTypePomodoro;
    case ActivitySource.manual:
      return l10n.activityTypeActivity;
  }
}

String _statusLabel(ActivityStatus status, AppLocalizations l10n) {
  switch (status) {
    case ActivityStatus.selesai:
      return l10n.activityStatusSelesai;
    case ActivityStatus.dilewati:
      return l10n.activityStatusDilewati;
    case ActivityStatus.belum_mulai:
      return l10n.activityStatusBelumMulai;
  }
}

Color? _categoryColor(ActivityHomeState state, ActivityRow activity) {
  final category = state.categories
      .where((c) => c.id == activity.activityCategoryId)
      .firstOrNull;
  if (category == null) return null;
  final clean = category.warna.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

String? _categoryName(ActivityHomeState state, ActivityRow activity) => state
    .categories
    .where((c) => c.id == activity.activityCategoryId)
    .firstOrNull
    ?.nama;

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.state, required this.l10n});
  final ActivityHomeState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final completed = state.activities
        .where((a) => a.status == ActivityStatus.selesai)
        .length;
    return Text(
      l10n.activityCompletionRate(
        completed,
        state.activities.length,
        state.completionRatePercent.toStringAsFixed(1),
      ),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _OverlapBanner extends StatelessWidget {
  const _OverlapBanner({required this.count, required this.l10n});
  final int count;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(l10n.activityOverlapWarning(count))),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

/// Reference `dh-entry` / `dh-feature`: a bordered card with a category dot-chip
/// + type on the left of the header row, the status on the right, a bold title
/// and a muted time/course line. The feature variant fills with the accent.
class _AgendaEntry extends StatelessWidget {
  const _AgendaEntry({
    required this.activity,
    required this.state,
    required this.cubit,
    required this.l10n,
    required this.feature,
    required this.onTap,
  });

  final ActivityRow activity;
  final ActivityHomeState state;
  final ActivityHomeCubit cubit;
  final AppLocalizations l10n;
  final bool feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final onSurface = feature ? colors.onPrimary : colors.onSurface;
    final muted = feature ? colors.onPrimary : colors.onSurfaceVariant;
    final chipColor =
        feature ? colors.onPrimary : (_categoryColor(state, activity) ?? muted);
    final categoryName = _categoryName(state, activity);
    final range = activity.startTime == null
        ? l10n.activityFlexible
        : '${cubit.formatTime(activity.startTime!)}'
            '${activity.endTime != null ? '–${cubit.formatTime(activity.endTime!)}' : ''}';
    final recurring = activity.source == ActivitySource.timebox &&
            activity.recurrenceId != null
        ? ' · ${l10n.activityRecurringWeekly}'
        : '';
    final subtitle = '$range$recurring';

    return Material(
      color: feature ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
            color: feature ? colors.primary : colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(feature ? 20 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Row(children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius:
                              BorderRadius.circular(AppRadius.status - 2))),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                        '${categoryName == null ? '' : '$categoryName · '}${_typeLabel(activity.source, l10n)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: chipColor)),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text(_statusLabel(activity.status, l10n),
                  style: TextStyle(fontSize: 11, color: muted)),
            ]),
            SizedBox(height: feature ? 11 : 7),
            Text(activity.judul,
                style: TextStyle(
                    fontSize: feature ? 21 : 15,
                    height: feature ? 1.25 : null,
                    letterSpacing: feature ? -0.4 : null,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                    decoration: activity.status == ActivityStatus.selesai
                        ? TextDecoration.lineThrough
                        : null)),
            SizedBox(height: feature ? 8 : 5),
            Text(subtitle, style: TextStyle(fontSize: 12, color: muted)),
            if (feature && activity.startTime != null) ...[
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(children: [
                  Expanded(
                      child: Text(l10n.activityPlannedRange(range),
                          style: TextStyle(fontSize: 12, color: muted))),
                  Text(l10n.activityOpenBlock,
                      style: TextStyle(fontSize: 12, color: muted)),
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Reference `dh-flexrow`: a checkbox to toggle completion + a tappable title.
class _FlexRow extends StatelessWidget {
  const _FlexRow({
    required this.activity,
    required this.state,
    required this.cubit,
    required this.l10n,
    required this.onTap,
  });

  final ActivityRow activity;
  final ActivityHomeState state;
  final ActivityHomeCubit cubit;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = activity.status == ActivityStatus.selesai;
    final categoryName = _categoryName(state, activity);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Checkbox(
            value: done,
            onChanged: (v) => cubit.setStatus(
                activity.id,
                (v ?? false)
                    ? ActivityStatus.selesai
                    : ActivityStatus.belum_mulai),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.judul,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration:
                                done ? TextDecoration.lineThrough : null)),
                    const SizedBox(height: 2),
                    Text(
                        '${categoryName == null ? '' : '$categoryName · '}${_statusLabel(activity.status, l10n)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Reference `dh-deadlinecard` / `dh-overdue`: due countdown in danger, title,
/// course line, and a status/priority meta row.
class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({
    required this.task,
    required this.cubit,
    required this.l10n,
    required this.locale,
  });

  final TugasRow task;
  final ActivityHomeCubit cubit;
  final AppLocalizations l10n;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final loc = tz.getLocation(cubit.timezone);
    final due = tz.TZDateTime.from(task.deadline, loc);
    final nowLocal = tz.TZDateTime.now(loc);
    final deltaDays = DateUtils.dateOnly(due)
        .difference(DateUtils.dateOnly(nowLocal))
        .inDays;
    final overdue = deltaDays < 0;
    final time = cubit.formatTime(task.deadline);
    final String dueLabel;
    if (overdue) {
      dueLabel = l10n.tugasDaysOverdue(-deltaDays);
    } else if (deltaDays == 0) {
      dueLabel = '${l10n.tugasDueToday} · $time';
    } else if (deltaDays == 1) {
      dueLabel = '${l10n.tugasDueTomorrow} · $time';
    } else {
      dueLabel = '${l10n.tugasDaysRemaining(deltaDays)} · $time';
    }
    final statusLabel = task.status == TugasStatus.progress
        ? l10n.taskStatusProgress
        : l10n.taskStatusNotStarted;
    final priorityLabel = switch (task.prioritas) {
      TugasPrioritas.low => l10n.taskPriorityLow,
      TugasPrioritas.medium => l10n.taskPriorityMedium,
      TugasPrioritas.high => l10n.taskPriorityHigh,
    };

    if (overdue) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dueLabel,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.error)),
          const SizedBox(height: 4),
          Text(task.judul, style: TextStyle(fontSize: 12, color: colors.error)),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(dueLabel,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: colors.error)),
        const SizedBox(height: 10),
        Text(task.judul, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 4, children: [
          Text(statusLabel, style: Theme.of(context).textTheme.labelSmall),
          Text(priorityLabel, style: Theme.of(context).textTheme.labelSmall),
        ]),
      ]),
    );
  }
}

/// Reference `dh-review`: a divider, heading, body line and an open button.
class _WeeklyReviewSection extends StatelessWidget {
  const _WeeklyReviewSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Divider(color: colors.outlineVariant),
      const SizedBox(height: AppSpacing.xl),
      Text(l10n.homeWeeklyReview,
          style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 7),
      Text(l10n.homeWeeklyReviewBody,
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 10),
      // The Weekly Review screen is not built in this M1 checkout.
      Tooltip(
        message: l10n.featureUnavailable,
        child: TextButton(
          onPressed: null,
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              foregroundColor: colors.primary),
          child: Text(l10n.homeWeeklyReviewOpen,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }
}

/// Reference `dh-weekgrid` / `dh-weekmobile`: the "Minggu" view. A 2-hour-bucket
/// grid (08.00–22.00) of the week's timed activities on wide screens, and a
/// stacked per-day list on phones. Deadlines for each day show as danger cells.
class _WeekGrid extends StatelessWidget {
  const _WeekGrid({
    required this.monday,
    required this.cubit,
    required this.state,
    required this.deadlines,
    required this.l10n,
    required this.locale,
    required this.mobile,
    required this.onActivityTap,
  });

  final DateTime monday;
  final ActivityHomeCubit cubit;
  final ActivityHomeState state;
  final Stream<List<TugasRow>> deadlines;
  final AppLocalizations l10n;
  final String locale;
  final bool mobile;
  final void Function(ActivityRow) onActivityTap;

  static const List<int> _hours = [8, 10, 12, 14, 16, 18, 20, 22];

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _bucket(int hour) => hour < 8 ? 8 : (hour > 22 ? 22 : (hour ~/ 2) * 2);

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final start = _ymd(days.first);
    final end = _ymd(days.last);
    return StreamBuilder<List<ActivityRow>>(
      stream: cubit.watchRange(start, end),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(children: [
            Text(l10n.homeReadFailed),
            TextButton(onPressed: cubit.retry, child: Text(l10n.actionRetry)),
          ]);
        }
        if (!snapshot.hasData) {
          return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()));
        }
        final timed = snapshot.data!
            .where((a) => !a.isAllDay && a.startTime != null)
            .toList();
        return StreamBuilder<List<TugasRow>>(
          stream: deadlines,
          builder: (context, dsnap) {
            final tasks = (dsnap.data ?? const <TugasRow>[])
                .where((t) =>
                    t.status != TugasStatus.selesai && t.archivedAt == null)
                .toList();
            return mobile
                ? _buildMobile(context, days, timed, tasks)
                : _buildGrid(context, days, timed, tasks);
          },
        );
      },
    );
  }

  DateTime _localStart(ActivityRow a) =>
      tz.TZDateTime.from(a.startTime!, tz.getLocation(cubit.timezone));
  DateTime _localDue(TugasRow t) =>
      tz.TZDateTime.from(t.deadline, tz.getLocation(cubit.timezone));

  Widget _buildGrid(BuildContext context, List<DateTime> days,
      List<ActivityRow> timed, List<TugasRow> tasks) {
    final colors = Theme.of(context).colorScheme;
    final border = BorderSide(color: colors.outlineVariant);
    Widget headCell(String text) => Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border(right: border, bottom: border)),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11)));

    final columnWidths = <int, TableColumnWidth>{0: const FixedColumnWidth(44)};
    for (var i = 1; i <= 7; i++) {
      columnWidths[i] = const FlexColumnWidth();
    }

    final rows = <TableRow>[
      TableRow(children: [
        headCell(l10n.homeWeekHour),
        for (final d in days)
          headCell(
              '${DateFormat.E(locale).format(d)}\n${DateFormat.MMMd(locale).format(d)}'),
      ]),
    ];
    for (final hour in _hours) {
      rows.add(TableRow(children: [
        Container(
            padding: const EdgeInsets.only(top: 12),
            decoration:
                BoxDecoration(border: Border(right: border, bottom: border)),
            child: Text('$hour.00',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant))),
        for (final d in days)
          _cell(context, d, hour, timed, tasks),
      ]));
    }

    return LayoutBuilder(builder: (context, constraints) {
      final grid = Container(
        width: constraints.maxWidth < 620 ? 620 : constraints.maxWidth,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.status + 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: rows),
      );
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: grid);
    });
  }

  Widget _cell(BuildContext context, DateTime day, int hour,
      List<ActivityRow> timed, List<TugasRow> tasks) {
    final colors = Theme.of(context).colorScheme;
    final border = BorderSide(color: colors.outlineVariant);
    final blocks = timed.where((a) {
      final s = _localStart(a);
      return _ymd(s) == _ymd(day) && _bucket(s.hour) == hour;
    }).toList();
    final due = tasks.where((t) {
      final s = _localDue(t);
      return _ymd(s) == _ymd(day) && _bucket(s.hour) == hour;
    }).toList();
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(border: Border(right: border, bottom: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final a in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Material(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.denseCell),
              child: InkWell(
                onTap: () => onActivityTap(a),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Text('${cubit.formatTime(a.startTime!)}\n${a.judul}',
                      style: TextStyle(fontSize: 10, color: colors.primary)),
                ),
              ),
            ),
          ),
        for (final t in due)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.denseCell)),
              child: Text(
                  '${l10n.tugasDeadlineLabel} ${cubit.formatTime(t.deadline)}\n${t.judul}',
                  style: TextStyle(fontSize: 10, color: colors.error)),
            ),
          ),
      ]),
    );
  }

  Widget _buildMobile(BuildContext context, List<DateTime> days,
      List<ActivityRow> timed, List<TugasRow> tasks) {
    final children = <Widget>[];
    for (final d in days) {
      final blocks = timed.where((a) => _ymd(_localStart(a)) == _ymd(d)).toList()
        ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
      final due = tasks.where((t) => _ymd(_localDue(t)) == _ymd(d)).toList();
      children.add(Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lgx, bottom: AppSpacing.sm),
        child: Text(
            DateFormat.MMMMEEEEd(locale).format(d),
            style: Theme.of(context).textTheme.titleSmall),
      ));
      if (blocks.isEmpty && due.isEmpty) {
        children.add(Text(l10n.homeNoDeadlines,
            style: Theme.of(context).textTheme.bodySmall));
      }
      for (final a in blocks) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _AgendaEntry(
              activity: a,
              state: state,
              cubit: cubit,
              l10n: l10n,
              feature: false,
              onTap: () => onActivityTap(a)),
        ));
      }
      for (final t in due) {
        final colors = Theme.of(context).colorScheme;
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.control)),
            child: Text(
                '${l10n.tugasDeadlineLabel} ${cubit.formatTime(t.deadline)} · ${t.judul}',
                style: TextStyle(fontSize: 12, color: colors.error)),
          ),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
