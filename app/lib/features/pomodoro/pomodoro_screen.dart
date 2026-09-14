import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/projections/pomodoro_stats.dart';
import '../../core/time/local_date.dart';
import '../../core/time/tz_data.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_screen.dart';
import '../shell/tugas_shell.dart';
import '../../app/theme/design_form.dart';
import 'pomodoro_cubit.dart';
import 'pomodoro_state.dart';

/// Pomodoro tab (design/screens/pomodoro.md; PRD Section 4.2, Section 7 "3.
/// Pomodoro"): timer, session link picker, and stats/history.
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.deviceId,
  });

  final AppDatabase db;
  final String userId;
  final String deviceId;

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  PomodoroCubit? _cubit;
  tz.Location? _location;
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
        _location = location;
        _cubit = PomodoroCubit(
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
    final location = _location;
    if (cubit == null || location == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navPomodoro)),
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
                  ])),
      );
    }
    return TugasShell(
        db: widget.db,
        userId: widget.userId,
        deviceId: widget.deviceId,
        activeIndex: 2,
        child: BlocBuilder<PomodoroCubit, PomodoroState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error == 'read') {
                return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(l10n.pomodoroReadFailed),
                  TextButton(
                      onPressed: cubit.retry, child: Text(l10n.actionRetry))
                ]));
              }
              return LayoutBuilder(builder: (context, constraints) {
                final mobile = MediaQuery.sizeOf(context).width <= 680;
                final wide = MediaQuery.sizeOf(context).width > 736 &&
                    constraints.maxWidth >= 550;
                Future<dynamic> settings() =>
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                            db: widget.db,
                            userId: widget.userId,
                            deviceId: widget.deviceId,
                            initialSection: 2)));
                final side = _StatsAndHistoryPane(
                    db: widget.db,
                    userId: widget.userId,
                    location: location,
                    l10n: l10n);
                return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: mobile
                            ? 16
                            : MediaQuery.sizeOf(context).width <= 860
                                ? 20
                                : MediaQuery.sizeOf(context).width >= 1150
                                    ? 38
                                    : 26,
                        vertical: mobile ? 22 : 32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.navPomodoro,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                  fontSize: mobile
                                                      ? 28
                                                      : MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <=
                                                              860
                                                          ? 26
                                                          : 30)),
                                      const SizedBox(height: 8),
                                      Text(l10n.pomodoroIntro,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall)
                                    ]),
                                OutlinedButton(
                                    onPressed: settings,
                                    child: Text(l10n.pomodoroTimerSettings))
                              ]),
                          const SizedBox(height: 26),
                          if (state.error == 'save')
                            Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(l10n.pomodoroSaveFailed,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error))),
                          if (wide)
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _TimerPane(
                                          cubit: cubit,
                                          state: state,
                                          l10n: l10n,
                                          db: widget.db,
                                          userId: widget.userId)),
                                  const SizedBox(width: 32),
                                  SizedBox(
                                      width: MediaQuery.sizeOf(context).width <=
                                              860
                                          ? 210
                                          : 258,
                                      child: Container(
                                          padding:
                                              const EdgeInsets.only(left: 26),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outlineVariant))),
                                          child: side))
                                ])
                          else
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _TimerPane(
                                      cubit: cubit,
                                      state: state,
                                      l10n: l10n,
                                      db: widget.db,
                                      userId: widget.userId),
                                  const SizedBox(height: 26),
                                  side
                                ]),
                        ]));
              });
            }));
  }
}

class _TimerPane extends StatefulWidget {
  const _TimerPane(
      {required this.cubit,
      required this.state,
      required this.l10n,
      required this.db,
      required this.userId});
  final PomodoroCubit cubit;
  final PomodoroState state;
  final AppLocalizations l10n;
  final AppDatabase db;
  final String userId;
  @override
  State<_TimerPane> createState() => _TimerPaneState();
}

class _TimerPaneState extends State<_TimerPane> {
  PomodoroJenis _phase = PomodoroJenis.fokus;
  int? _overrideMinutes;
  String? _linkedTugasId;
  String label(PomodoroJenis phase) => switch (phase) {
        PomodoroJenis.fokus => widget.l10n.pomodoroFokus,
        PomodoroJenis.istirahat_pendek => widget.l10n.pomodoroShortBreak,
        PomodoroJenis.istirahat_panjang => widget.l10n.pomodoroLongBreak,
      };
  @override
  Widget build(BuildContext context) {
    final state = widget.state, l10n = widget.l10n;
    final current = state.current;
    final phase = current?.jenis ?? _phase;
    final minutes = current?.durasiMenit ??
        switch (phase) {
          PomodoroJenis.fokus => _overrideMinutes ?? state.focusMinutes,
          PomodoroJenis.istirahat_pendek => state.shortBreakMinutes,
          PomodoroJenis.istirahat_panjang => state.longBreakMinutes,
        };
    final seconds = current == null ? minutes * 60 : state.remainingSeconds;
    final theme = Theme.of(context), colors = theme.colorScheme;
    final status = current == null
        ? l10n.pomodoroIdle
        : state.isPaused
            ? l10n.pomodoroStatusPaused
            : l10n.pomodoroStatusRunning;
    final startLabel = switch (phase) {
      PomodoroJenis.fokus => l10n.pomodoroStartFocus,
      PomodoroJenis.istirahat_pendek => l10n.pomodoroStartShortBreak,
      PomodoroJenis.istirahat_panjang => l10n.pomodoroStartLongBreak,
    };
    return Column(children: [
      Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 5,
          children: [
            for (final p in PomodoroJenis.values)
              TextButton(
                  onPressed: current != null || state.busy
                      ? null
                      : () => setState(() => _phase = p),
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      backgroundColor:
                          p == phase ? colors.onSurface : Colors.transparent,
                      foregroundColor:
                          p == phase ? colors.surface : colors.onSurface),
                  child: Text(label(p))),
          ]),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, constraints) {
        final diameter = constraints.maxWidth.clamp(
            0.0, MediaQuery.sizeOf(context).width <= 680 ? 290.0 : MediaQuery.sizeOf(context).width <= 860 ? 270.0 : 310.0);
        return SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(
                  child: CircularProgressIndicator(
                      value: current == null
                          ? 1
                          : (state.remainingSeconds / (minutes * 60))
                              .clamp(0, 1),
                      strokeWidth: 9,
                      backgroundColor: colors.outlineVariant,
                      color: colors.primary,
                      semanticsLabel: label(phase))),
              Padding(
                  padding: const EdgeInsets.all(24),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                            '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -3,
                                fontFeatures: [FontFeature.tabularFigures()])),
                        const SizedBox(height: 8),
                        Text(status, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text(
                            '${label(phase)} · ${l10n.pomodoroMinutes(minutes)}',
                            style: theme.textTheme.bodySmall),
                        if (state.isOvertime)
                          Text(l10n.pomodoroOvertime,
                              style:
                                  TextStyle(fontSize: 12, color: colors.error)),
                      ]))),
            ]));
      }),
      const SizedBox(height: 20),
      if (current == null) ...[
        if (phase == PomodoroJenis.fokus) ...[
          Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in [25, 50, 90])
                  OutlinedButton(
                      onPressed: state.busy
                          ? null
                          : () => setState(() => _overrideMinutes = n),
                      style: OutlinedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 12),
                          backgroundColor:
                              minutes == n ? colors.primaryContainer : null,
                          side: BorderSide(
                              color: minutes == n
                                  ? colors.primary
                                  : colors.outline)),
                      child: Text(l10n.pomodoroMinutes(n))),
                OutlinedButton(
                    onPressed: state.busy
                        ? null
                        : () async {
                            final n = await _customMinutes();
                            if (n != null && mounted) {
                              setState(() => _overrideMinutes = n);
                            }
                          },
                    child: Text(l10n.pomodoroCustomPreset,
                        style: const TextStyle(fontSize: 12))),
              ]),
          const SizedBox(height: 20),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: DesignField(
                  label: l10n.pomodoroFocusFor,
                  child: _LinkPickerButton(
                      db: widget.db,
                      userId: widget.userId,
                      linkedTugasId: _linkedTugasId,
                      l10n: l10n,
                      onChanged: (id) => setState(() => _linkedTugasId = id)))),
          const SizedBox(height: 20),
        ],
        FilledButton(
            onPressed: state.busy
                ? null
                : () => widget.cubit.start(
                    jenis: phase,
                    overrideMinutes:
                        phase == PomodoroJenis.fokus ? _overrideMinutes : null,
                    tugasId:
                        phase == PomodoroJenis.fokus ? _linkedTugasId : null),
            child: Text(startLabel)),
        if (state.shouldOfferLongBreak)
          TextButton(
              onPressed: state.busy
                  ? null
                  : () =>
                      setState(() => _phase = PomodoroJenis.istirahat_panjang),
              child: Text(l10n.pomodoroOfferLongBreak)),
      ] else
        _RunningControls(
            cubit: widget.cubit,
            current: current,
            l10n: l10n,
            busy: state.busy),
      const SizedBox(height: 18),
      ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Text(
              '${l10n.pomodoroManualNote} ${l10n.pomodoroLongBreakCount(state.focusStreakSinceLongBreak, state.longBreakInterval)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall)),
    ]);
  }

  Future<int?> _customMinutes() async {
    final controller = TextEditingController();
    String? error;
    final route = DialogRoute<int>(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
              void save() {
                final n = int.tryParse(controller.text.trim());
                if (n == null || n < 1 || n > 180) {
                  setModal(() => error = widget.l10n.pomodoroCustomInvalid);
                  return;
                }
                Navigator.of(ctx).pop(n);
              }

              return Dialog(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: DesignModal(
                          title: widget.l10n.pomodoroCustomPreset,
                          saveLabel: widget.l10n.tugasSave,
                          onSave: save,
                          children: [
                            DesignField(
                                label: widget.l10n.pomodoroCustomMinutesLabel,
                                child: TextField(
                                    controller: controller,
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 16),
                                    onSubmitted: (_) => save(),
                                    decoration:
                                        InputDecoration(errorText: error)))
                          ])));
            }));
    final result = await Navigator.of(context).push(route);
    await route.completed;
    controller.dispose();
    return result;
  }
}

class _LinkPickerButton extends StatelessWidget {
  const _LinkPickerButton({
    required this.db,
    required this.userId,
    required this.linkedTugasId,
    required this.l10n,
    required this.onChanged,
  });

  final AppDatabase db;
  final String userId;
  final String? linkedTugasId;
  final AppLocalizations l10n;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TugasRow>>(
      stream: db.tugasDao.watchActiveTugas(userId),
      builder: (context, snapshot) {
        final options = snapshot.data ?? const <TugasRow>[];
        final linked = options.where((t) => t.id == linkedTugasId).firstOrNull;
        return OutlinedButton.icon(
          icon: const Icon(Icons.link, size: 18),
          label: Text(linked == null ? l10n.pomodoroLinkFree : linked.judul,
              softWrap: true),
          onPressed: () async {
            final picked = await showDialog<String>(
                context: context,
                builder: (ctx) => Dialog(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 540),
                        child: DesignModal(
                            title: l10n.pomodoroFocusFor,
                            saveLabel: l10n.actionCancel,
                            showSave: false,
                            onSave: () => Navigator.of(ctx).pop(),
                            children: [
                              ListTile(
                                  title: Text(l10n.pomodoroLinkFree),
                                  onTap: () => Navigator.of(ctx).pop('')),
                              Text(l10n.pomodoroHabitUnavailable,
                                  style: Theme.of(ctx).textTheme.bodySmall),
                              for (final t
                                  in options.where((t) => t.archivedAt == null))
                                ListTile(
                                    title: Text(t.judul),
                                    onTap: () => Navigator.of(ctx).pop(t.id)),
                            ]))));
            if (picked != null && context.mounted) {
              onChanged(picked.isEmpty ? null : picked);
            }
          },
        );
      },
    );
  }
}

class _RunningControls extends StatelessWidget {
  const _RunningControls(
      {required this.cubit,
      required this.current,
      required this.l10n,
      required this.busy});
  final PomodoroCubit cubit;
  final PomodoroSessionRow current;
  final bool busy;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final paused = current.status == PomodoroStatus.paused;
    return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          if (paused)
            FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.pomodoroResume),
                onPressed: busy ? null : cubit.resume)
          else
            FilledButton.icon(
                icon: const Icon(Icons.pause),
                label: Text(l10n.pomodoroPause),
                onPressed: busy ? null : cubit.pause),
          OutlinedButton.icon(
              icon: const Icon(Icons.check),
              label: Text(l10n.pomodoroCompleteSession),
              onPressed: busy ? null : cubit.complete),
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: Text(current.jenis == PomodoroJenis.fokus
                ? l10n.pomodoroCancelSession
                : l10n.pomodoroSkipBreak),
            onPressed: busy
                ? null
                : () async {
                    // FR-2.9: confirmation only for cancelling a focus session; skipping
                    // a break needs none.
                    if (current.jenis == PomodoroJenis.fokus) {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.pomodoroCancelConfirmTitle),
                          content: Text(l10n.pomodoroCancelConfirmBody),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: Text(l10n.actionBack)),
                            FilledButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: Text(l10n.pomodoroCancelConfirmAction)),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                    }
                    await cubit.cancel();
                  },
          ),
        ]);
  }
}

class _StatsAndHistoryPane extends StatefulWidget {
  const _StatsAndHistoryPane({
    required this.db,
    required this.userId,
    required this.location,
    required this.l10n,
  });

  final AppDatabase db;
  final String userId;
  final tz.Location location;
  final AppLocalizations l10n;

  @override
  State<_StatsAndHistoryPane> createState() => _StatsAndHistoryPaneState();
}

class _StatsAndHistoryPaneState extends State<_StatsAndHistoryPane> {
  AppDatabase get db => widget.db;
  String get userId => widget.userId;
  tz.Location get location => widget.location;
  AppLocalizations get l10n => widget.l10n;
  late Stream<List<PomodoroSessionRow>> _completed;
  late Stream<List<PomodoroSessionRow>> _history;
  int _period = 0;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _completed = db.pomodoroDao.watchCompletedFocusSessions(userId);
    _history = db.pomodoroDao.watchRecent(userId, limit: 10);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PomodoroSessionRow>>(
      stream: _completed,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(children: [
            Text(l10n.pomodoroReadFailed),
            TextButton(
                onPressed: () => setState(_reload),
                child: Text(l10n.actionRetry))
          ]);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final daily = groupPomodoroByDay(snapshot.data ?? const [], location);
        final today = LocalDate.fromInstant(DateTime.now().toUtc(), location);
        final weekStart = today.addDays(-(today.weekday - 1));
        final monthStart = LocalDate(today.year, today.month, 1);
        final todayStat = aggregatePomodoroPeriod(daily,
            periodStart: today, periodEnd: today);
        final weekStat = aggregatePomodoroPeriod(daily,
            periodStart: weekStart, periodEnd: today);
        final monthStat = aggregatePomodoroPeriod(daily,
            periodStart: monthStart, periodEnd: today);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.pomodoroFocusTime,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 20)),
              const SizedBox(height: 16),
          DropdownButtonFormField<int>(
              isExpanded: true,
                  initialValue: _period,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13),
                  items: [
                    DropdownMenuItem(
                        value: 0, child: Text(l10n.pomodoroStatsDaily)),
                    DropdownMenuItem(
                        value: 1, child: Text(l10n.pomodoroStatsWeekly)),
                    DropdownMenuItem(
                        value: 2, child: Text(l10n.pomodoroStatsMonthly))
                  ],
                  onChanged: (n) {
                    if (n != null) setState(() => _period = n);
                  }),
              const SizedBox(height: 24),
              Text(
                  l10n.pomodoroStatValue(
                      [todayStat, weekStat, monthStat][_period]
                              .totalActualSeconds ~/
                          60,
                      [todayStat, weekStat, monthStat][_period].sessionCount),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 32)),
              const SizedBox(height: AppSpacing.xl),
              Text(l10n.pomodoroHistoryTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              StreamBuilder<List<PomodoroSessionRow>>(
                stream: _history,
                builder: (context, historySnap) {
                  if (historySnap.hasError) {
                    return Text(l10n.pomodoroReadFailed);
                  }
                  if (!historySnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rows = historySnap.data ?? const <PomodoroSessionRow>[];
                  if (rows.isEmpty) {
                    return Text(l10n.pomodoroHistoryEmpty,
                        style: Theme.of(context).textTheme.bodySmall);
                  }
                  return Column(children: [
                    for (final r in rows) _historyRow(context, r, l10n)
                  ]);
                },
              ),
            ]);
      },
    );
  }

  Widget _historyRow(
      BuildContext context, PomodoroSessionRow r, AppLocalizations l10n) {
    final local = tz.TZDateTime.from(r.startTime, location);
    final timeLabel =
        "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
    String statusLabel;
    switch (r.status) {
      case PomodoroStatus.completed:
        statusLabel = l10n.activityStatusSelesai;
      case PomodoroStatus.cancelled:
        statusLabel = l10n.pomodoroStatusCancelled;
      case PomodoroStatus.running:
        statusLabel = l10n.pomodoroStatusRunning;
      case PomodoroStatus.paused:
        statusLabel = l10n.pomodoroStatusPaused;
    }
    String jenisLabel;
    switch (r.jenis) {
      case PomodoroJenis.fokus:
        jenisLabel = l10n.pomodoroFokus;
      case PomodoroJenis.istirahat_pendek:
        jenisLabel = l10n.pomodoroShortBreak;
      case PomodoroJenis.istirahat_panjang:
        jenisLabel = l10n.pomodoroLongBreak;
    }
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant))),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('$jenisLabel · $statusLabel',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('${local.day}/${local.month}/${local.year} · $timeLabel',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
              '${l10n.pomodoroActual}: ${l10n.pomodoroMinutes((r.actualSeconds ?? 0) ~/ 60)} · ${l10n.pomodoroPlanned}: ${l10n.pomodoroMinutes(r.durasiMenit)}',
              style: Theme.of(context).textTheme.bodySmall),
        ]));
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
