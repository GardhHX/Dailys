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
import 'activity_home_cubit.dart';
import 'activity_home_state.dart';
import 'add_activity_sheet.dart';
import 'next_deadline_panel.dart';

/// Home Today (design/screens/home.md, M1 subset): active-date occurrence
/// list split into scheduled/no-time sections, completion rate, overlap
/// warnings, date navigation, add/status/delete actions, and the Next
/// Deadline companion panel (FR-6.6, FR-6.8–FR-6.10, FR-6.17). Timebox grid,
/// Weekly Grid, Habits panel, and the Weekly Review shortcut are M3–M5 and
/// intentionally absent rather than faked (M1-PLAN Section 4).
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

class _ActivityHomeScreenState extends State<ActivityHomeScreen> {
  ActivityHomeCubit? _cubit;
  tz.Location? _location;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    ensureTimeZoneDatabaseLoaded();
    final settings = await widget.db.settingsDao.getUserSettings(widget.userId);
    final location = tz.getLocation(settings?.timezone ?? 'Asia/Jakarta');
    if (!mounted) return;
    setState(() {
      _location = location;
      _cubit = ActivityHomeCubit(db: widget.db, userId: widget.userId, location: location);
    });
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return BlocBuilder<ActivityHomeCubit, ActivityHomeState>(
      bloc: cubit,
      builder: (context, state) {
        final dateLabel = DateFormat.yMMMEd(locale).format(
          DateTime(state.date.year, state.date.month, state.date.day),
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(dateLabel),
            actions: [
              IconButton(
                icon: const Icon(Icons.today_outlined),
                tooltip: l10n.activityToday,
                onPressed: cubit.goToToday,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => _pickDate(context, state.date),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    db: widget.db,
                    userId: widget.userId,
                    deviceId: widget.deviceId,
                  ),
                )),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: cubit.goToPreviousDay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: cubit.goToNextDay,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showAddActivitySheet(context, cubit: cubit),
            child: const Icon(Icons.add),
          ),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _CompletionBadge(state: state, l10n: l10n),
                    if (state.overlaps.isNotEmpty)
                      _OverlapBanner(count: state.overlaps.length, l10n: l10n),
                    if (state.activities.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                        child: Center(child: Text(l10n.activityEmpty)),
                      ),
                    if (state.timed.isNotEmpty) ...[
                      _SectionHeader(title: l10n.activityScheduledSection),
                      for (final a in state.timed)
                        _ActivityTile(activity: a, state: state, cubit: cubit, l10n: l10n),
                    ],
                    if (state.untimed.isNotEmpty) ...[
                      _SectionHeader(title: l10n.activityUnscheduledSection),
                      for (final a in state.untimed)
                        _ActivityTile(activity: a, state: state, cubit: cubit, l10n: l10n),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    NextDeadlinePanel(
                      db: widget.db,
                      userId: widget.userId,
                      location: _location!,
                    ),
                  ],
                ),
        );
      },
    );
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

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.state, required this.l10n});
  final ActivityHomeState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final completed = state.activities.where((a) => a.status == ActivityStatus.selesai).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        l10n.activityCompletionRate(
          completed,
          state.activities.length,
          state.completionRatePercent.toStringAsFixed(1),
        ),
        style: Theme.of(context).textTheme.titleMedium,
      ),
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
          Text(l10n.activityOverlapWarning(count)),
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.state,
    required this.cubit,
    required this.l10n,
  });

  final ActivityRow activity;
  final ActivityHomeState state;
  final ActivityHomeCubit cubit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final category = state.categories.where((c) => c.id == activity.activityCategoryId).firstOrNull;
    final color = category != null ? _parseHexColor(category.warna) : Colors.grey;
    final subtitle = activity.isAllDay
        ? l10n.activityAllDay
        : activity.startTime == null
            ? l10n.activityFlexible
            : '${TimeOfDay.fromDateTime(activity.startTime!.toLocal()).format(context)}'
                '${activity.endTime != null ? ' – ${TimeOfDay.fromDateTime(activity.endTime!.toLocal()).format(context)}' : ''}';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 8),
        title: Text(
          activity.judul,
          style: activity.status == ActivityStatus.selesai
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text('$subtitle · ${_statusLabel(activity.status, l10n)}'),
        trailing: PopupMenuButton<ActivityStatus>(
          onSelected: (s) => cubit.setStatus(activity.id, s),
          itemBuilder: (context) => [
            if (activity.status != ActivityStatus.selesai)
              PopupMenuItem(value: ActivityStatus.selesai, child: Text(l10n.activityMarkDone)),
            if (activity.status != ActivityStatus.dilewati)
              PopupMenuItem(value: ActivityStatus.dilewati, child: Text(l10n.activityMarkSkipped)),
            if (activity.status != ActivityStatus.belum_mulai)
              PopupMenuItem(value: ActivityStatus.belum_mulai, child: Text(l10n.activityReopen)),
          ],
        ),
        onLongPress: () => cubit.deleteActivity(activity.id),
      ),
    );
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

  Color _parseHexColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
