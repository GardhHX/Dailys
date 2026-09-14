import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/time/local_date.dart';
import '../../core/time/tz_data.dart';
import '../../l10n/app_localizations.dart';
import 'habit_cubit.dart';
import 'habit_screen.dart';
import 'habit_state.dart';

/// Habit detail route (design/screens/habit.md "Detail memakai route dengan
/// tombol kembali"): current/longest streak, target hari, a 4-week
/// prev/next-navigable heatmap, per-date note/status, edit, jeda/lanjutkan,
/// and hapus.
class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.habitId,
  });

  final AppDatabase db;
  final String userId;
  final String habitId;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  HabitCubit? _cubit;
  String? _initError;

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
        _cubit = HabitCubit(
            db: widget.db, userId: widget.userId, location: location);
      });
    } catch (_) {
      if (mounted) setState(() => _initError = 'load');
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
          appBar: AppBar(),
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
    return BlocBuilder<HabitCubit, HabitState>(
      bloc: cubit,
      builder: (context, state) {
        final item = state.items
            .where((i) => i.habit.id == widget.habitId)
            .firstOrNull;
        if (state.loading) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }
        if (item == null) {
          // Deleted or unavailable — leave the route.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
          return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
        }
        return _HabitDetailBody(cubit: cubit, item: item, l10n: l10n);
      },
    );
  }
}

class _HabitDetailBody extends StatefulWidget {
  const _HabitDetailBody(
      {required this.cubit, required this.item, required this.l10n});
  final HabitCubit cubit;
  final HabitListItem item;
  final AppLocalizations l10n;

  @override
  State<_HabitDetailBody> createState() => _HabitDetailBodyState();
}

class _HabitDetailBodyState extends State<_HabitDetailBody> {
  /// Number of 4-week blocks shifted from the block ending this week; 0 is
  /// the most recent, negative values move further into the past.
  int _blockOffset = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final habit = widget.item.habit;
    final mobile = MediaQuery.sizeOf(context).width <= 680;
    final today = widget.cubit.today;
    final currentMonday = today.addDays(-(today.weekday - 1));
    final blockEndMonday = currentMonday.addDays(_blockOffset * 28);
    final gridStart = blockEndMonday.addDays(-21);
    final gridEnd = blockEndMonday.addDays(6);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.nama),
        actions: [
          IconButton(
              tooltip: l10n.habitDetailEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: HabitFormModal(
                              cubit: widget.cubit, existing: widget.item))))),
          IconButton(
              tooltip: habit.isArchived ? l10n.habitResume : l10n.habitPause,
              icon: Icon(
                  habit.isArchived ? Icons.play_arrow : Icons.pause_circle_outlined),
              onPressed: () => _confirmPauseResume(context, habit.isArchived)),
          IconButton(
              tooltip: l10n.habitDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: mobile ? 16 : 32, vertical: mobile ? 20 : 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: _StatTile(
                    label: l10n.habitDetailStreakCurrent,
                    value: '${habit.currentStreak}')),
            const SizedBox(width: 16),
            Expanded(
                child: _StatTile(
                    label: l10n.habitDetailStreakLongest,
                    value: '${habit.longestStreak}')),
          ]),
          const SizedBox(height: AppSpacing.lg),
          StreamBuilder<List<HabitScheduleRow>>(
            stream: widget.cubit.watchSchedules(habit.id),
            builder: (context, scheduleSnap) {
              final schedules = scheduleSnap.data ?? const <HabitScheduleRow>[];
              final labels = weekdayShortLabels(context);
              final current = widget.item.scheduleToday;
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.habitDetailTargetDays,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                        current == null
                            ? '—'
                            : current.targetHari
                                .map((w) => labels[w - 1])
                                .join(', '),
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                        '${l10n.habitDetailQuota}: ${current?.maxIzinPerMinggu ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.habitDetailHeatmap,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () =>
                              setState(() => _blockOffset -= 1)),
                      Expanded(
                          child: Text(
                              '${gridStart.toYmd()} — ${gridEnd.toYmd()}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall)),
                      IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _blockOffset >= 0
                              ? null
                              : () => setState(() => _blockOffset += 1)),
                    ]),
                    StreamBuilder<List<HabitLogRow>>(
                      stream: widget.cubit.watchLogs(habit.id,
                          startDate: gridStart.toYmd(),
                          endDate: gridEnd.toYmd()),
                      builder: (context, logSnap) {
                        final logs = logSnap.data ?? const <HabitLogRow>[];
                        final logByDate = {
                          for (final log in logs) log.tanggal: log
                        };
                        return _Heatmap(
                          gridStart: gridStart,
                          schedules: schedules,
                          logByDate: logByDate,
                          today: today,
                          l10n: l10n,
                          onTapDate: (date) async {
                            final remaining = await widget.cubit
                                .remainingIzinForDate(habit.id, date);
                            if (!context.mounted) return;
                            showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                    child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 440),
                                        child: HabitLogModal(
                                            cubit: widget.cubit,
                                            habitId: habit.id,
                                            tanggal: date,
                                            existing: logByDate[date.toYmd()],
                                            remainingIzin: remaining))));
                          },
                        );
                      },
                    ),
                  ]);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _confirmPauseResume(BuildContext context, bool isArchived) async {
    final l10n = widget.l10n;
    if (!isArchived) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.habitPauseConfirmTitle),
          content: Text(l10n.habitPauseConfirmBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.actionCancel)),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.habitPause)),
          ],
        ),
      );
      if (ok != true) return;
    }
    await widget.cubit.setArchived(widget.item.habit.id, isArchived: !isArchived);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = widget.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.habitDeleteConfirmTitle),
        content: Text(l10n.habitDeleteConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.habitDelete)),
        ],
      ),
    );
    if (ok == true) {
      await widget.cubit.delete(widget.item.habit.id);
      if (context.mounted) Navigator.of(context).maybePop();
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ]));
}

enum _DaySymbol { done, skip, missed, nonTarget, paused, pendingToday }

class _Heatmap extends StatelessWidget {
  const _Heatmap({
    required this.gridStart,
    required this.schedules,
    required this.logByDate,
    required this.today,
    required this.l10n,
    required this.onTapDate,
  });

  final LocalDate gridStart;
  final List<HabitScheduleRow> schedules;
  final Map<String, HabitLogRow> logByDate;
  final LocalDate today;
  final AppLocalizations l10n;
  final ValueChanged<LocalDate> onTapDate;

  HabitScheduleRow? _scheduleFor(LocalDate date) {
    final ymd = date.toYmd();
    for (final s in schedules) {
      if (s.effectiveFrom.compareTo(ymd) <= 0 &&
          (s.effectiveTo == null || s.effectiveTo!.compareTo(ymd) >= 0)) {
        return s;
      }
    }
    return null;
  }

  _DaySymbol _symbolFor(LocalDate date) {
    final schedule = _scheduleFor(date);
    if (schedule == null) return _DaySymbol.nonTarget;
    if (schedule.state == HabitScheduleState.paused) return _DaySymbol.paused;
    if (!schedule.targetHari.contains(date.weekday)) return _DaySymbol.nonTarget;
    final log = logByDate[date.toYmd()];
    if (log == null) {
      return date == today ? _DaySymbol.pendingToday : _DaySymbol.missed;
    }
    return switch (log.status) {
      HabitLogStatus.done => _DaySymbol.done,
      HabitLogStatus.skip => _DaySymbol.skip,
      HabitLogStatus.missed => _DaySymbol.missed,
    };
  }

  String _glyph(_DaySymbol s) => switch (s) {
        _DaySymbol.done => '✓',
        _DaySymbol.skip => 'I',
        _DaySymbol.missed => '×',
        _DaySymbol.nonTarget => '·',
        _DaySymbol.paused => 'J',
        _DaySymbol.pendingToday => '○',
      };

  String _label(_DaySymbol s) => switch (s) {
        _DaySymbol.done => l10n.habitStatusDone,
        _DaySymbol.skip => l10n.habitStatusSkip,
        _DaySymbol.missed => l10n.habitStatusMissed,
        _DaySymbol.nonTarget => l10n.habitStatusNone,
        _DaySymbol.paused => l10n.habitTabPaused,
        _DaySymbol.pendingToday => l10n.habitStatusNone,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labels = weekdayShortLabels(context);
    return Column(children: [
      Row(
          children: [
            for (final l in labels)
              Expanded(
                  child: Center(
                      child: Text(l, style: Theme.of(context).textTheme.bodySmall)))
          ]),
      for (var week = 0; week < 4; week++)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            for (var day = 0; day < 7; day++)
              Expanded(
                child: Builder(builder: (context) {
                  final date = gridStart.addDays(week * 7 + day);
                  final symbol = _symbolFor(date);
                  final future = date.isAfter(today);
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: Semantics(
                      label: '${date.toYmd()} ${_label(symbol)}',
                      child: InkWell(
                        onTap: future ? null : () => onTapDate(date),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: future
                                  ? colors.surface
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(future ? '' : _glyph(symbol),
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
          ]),
        ),
    ]);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
