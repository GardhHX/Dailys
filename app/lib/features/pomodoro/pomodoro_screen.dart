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
      final settings = await widget.db.settingsDao.getUserSettings(widget.userId);
      final location = tz.getLocation(settings?.timezone ?? 'Asia/Jakarta');
      if (!mounted) return;
      setState(() {
        _location = location;
        _cubit = PomodoroCubit(db: widget.db, userId: widget.userId, location: location);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPomodoro),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingsScreen(
                    db: widget.db, userId: widget.userId, deviceId: widget.deviceId))),
            child: Text(l10n.pomodoroSettingsShortcut),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<PomodoroCubit, PomodoroState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 860;
            final timer = _TimerPane(
                cubit: cubit,
                state: state,
                l10n: l10n,
                db: widget.db,
                userId: widget.userId);
            final side = _StatsAndHistoryPane(
                db: widget.db, userId: widget.userId, location: location, l10n: l10n);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: wide
                  ? IntrinsicHeight(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 3, child: timer),
                      const SizedBox(width: AppSpacing.xxl),
                      Expanded(flex: 2, child: side),
                    ]))
                  : Column(children: [timer, const SizedBox(height: AppSpacing.xxl), side]),
            );
          });
        },
      ),
    );
  }
}

class _TimerPane extends StatelessWidget {
  const _TimerPane({
    required this.cubit,
    required this.state,
    required this.l10n,
    required this.db,
    required this.userId,
  });
  final PomodoroCubit cubit;
  final PomodoroState state;
  final AppLocalizations l10n;
  final AppDatabase db;
  final String userId;

  String _jenisLabel(PomodoroJenis jenis) {
    switch (jenis) {
      case PomodoroJenis.fokus:
        return l10n.pomodoroFokus;
      case PomodoroJenis.istirahat_pendek:
        return l10n.pomodoroShortBreak;
      case PomodoroJenis.istirahat_panjang:
        return l10n.pomodoroLongBreak;
    }
  }

  String _mmss(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final current = state.current;
    return Column(children: [
      if (state.shouldOfferLongBreak)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
              color: colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.control)),
          child: Row(children: [
            Expanded(child: Text(l10n.pomodoroOfferLongBreak)),
            TextButton(
                onPressed: () => cubit.start(jenis: PomodoroJenis.istirahat_panjang),
                child: Text(l10n.pomodoroStartLongBreak)),
          ]),
        ),
      SizedBox(
        width: 260,
        height: 260,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: current == null
                  ? 0
                  : (state.elapsedSeconds / (current.durasiMenit * 60)).clamp(0, 1),
              strokeWidth: 10,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                  current?.jenis == PomodoroJenis.fokus ? colors.primary : colors.tertiary),
            ),
          ),
          // FittedBox keeps the mm:ss + phase label readable inside the fixed
          // circle even at large system text-scale factors, rather than
          // overflowing it.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_mmss(state.remainingSeconds),
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()])),
                const SizedBox(height: 4),
                Text(current == null ? l10n.pomodoroIdle : _jenisLabel(current.jenis),
                    style: Theme.of(context).textTheme.bodyMedium),
                if (state.isOvertime)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l10n.pomodoroOvertime,
                        style: TextStyle(color: colors.error, fontSize: 12)),
                  ),
              ]),
            ),
          ),
        ]),
      ),
      const SizedBox(height: AppSpacing.xl),
      if (current == null)
        _IdleControls(cubit: cubit, state: state, l10n: l10n, db: db, userId: userId)
      else
        _RunningControls(cubit: cubit, current: current, l10n: l10n),
    ]);
  }
}

class _IdleControls extends StatefulWidget {
  const _IdleControls({
    required this.cubit,
    required this.state,
    required this.l10n,
    required this.db,
    required this.userId,
  });
  final PomodoroCubit cubit;
  final PomodoroState state;
  final AppLocalizations l10n;
  final AppDatabase db;
  final String userId;

  @override
  State<_IdleControls> createState() => _IdleControlsState();
}

class _IdleControlsState extends State<_IdleControls> {
  static const _presets = [25, 50, 90];
  int? _overrideMinutes;
  String? _linkedTugasId;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Column(children: [
      Text(l10n.pomodoroPresetLabel, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: AppSpacing.sm),
      Wrap(spacing: AppSpacing.sm, alignment: WrapAlignment.center, children: [
        for (final p in _presets)
          ChoiceChip(
            label: Text(l10n.pomodoroMinutes(p)),
            selected: _overrideMinutes == p,
            onSelected: (v) => setState(() => _overrideMinutes = v ? p : null),
          ),
        ActionChip(
          label: Text(l10n.pomodoroCustomPreset),
          onPressed: () async {
            final minutes = await _pickCustomMinutes(context);
            if (minutes != null) setState(() => _overrideMinutes = minutes);
          },
        ),
      ]),
      const SizedBox(height: AppSpacing.md),
      _LinkPickerButton(
        db: widget.db,
        userId: widget.userId,
        linkedTugasId: _linkedTugasId,
        l10n: l10n,
        onChanged: (id) => setState(() => _linkedTugasId = id),
      ),
      const SizedBox(height: AppSpacing.lg),
      FilledButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.pomodoroStartFocus),
        onPressed: () => widget.cubit.start(
            jenis: PomodoroJenis.fokus,
            overrideMinutes: _overrideMinutes,
            tugasId: _linkedTugasId),
      ),
      const SizedBox(height: AppSpacing.sm),
      Wrap(spacing: AppSpacing.sm, alignment: WrapAlignment.center, children: [
        OutlinedButton(
          onPressed: () => widget.cubit.start(jenis: PomodoroJenis.istirahat_pendek),
          child: Text(l10n.pomodoroStartShortBreak),
        ),
        OutlinedButton(
          onPressed: () => widget.cubit.start(jenis: PomodoroJenis.istirahat_panjang),
          child: Text(l10n.pomodoroStartLongBreak),
        ),
      ]),
    ]);
  }

  Future<int?> _pickCustomMinutes(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(widget.l10n.pomodoroCustomPreset),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: widget.l10n.pomodoroCustomMinutesLabel),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(widget.l10n.closeDialog)),
          FilledButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, (minutes != null && minutes > 0) ? minutes : null);
            },
            child: Text(widget.l10n.actionContinue),
          ),
        ],
      ),
    );
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
              overflow: TextOverflow.ellipsis),
          onPressed: () async {
            final picked = await showModalBottomSheet<String?>(
              context: context,
              builder: (sheetContext) => SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ListTile(
                      title: Text(l10n.pomodoroLinkFree),
                      onTap: () => Navigator.pop(sheetContext, null)),
                  for (final t in options)
                    ListTile(
                        title: Text(t.judul), onTap: () => Navigator.pop(sheetContext, t.id)),
                ]),
              ),
            );
            onChanged(picked);
          },
        );
      },
    );
  }
}

class _RunningControls extends StatelessWidget {
  const _RunningControls({required this.cubit, required this.current, required this.l10n});
  final PomodoroCubit cubit;
  final PomodoroSessionRow current;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final paused = current.status == PomodoroStatus.paused;
    return Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, alignment: WrapAlignment.center, children: [
      if (paused)
        FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.pomodoroResume),
            onPressed: cubit.resume)
      else
        FilledButton.icon(
            icon: const Icon(Icons.pause),
            label: Text(l10n.pomodoroPause),
            onPressed: cubit.pause),
      OutlinedButton.icon(
          icon: const Icon(Icons.check),
          label: Text(l10n.pomodoroCompleteSession),
          onPressed: cubit.complete),
      OutlinedButton.icon(
        icon: const Icon(Icons.close),
        label: Text(current.jenis == PomodoroJenis.fokus
            ? l10n.pomodoroCancelSession
            : l10n.pomodoroSkipBreak),
        onPressed: () async {
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
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(l10n.actionBack)),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
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

class _StatsAndHistoryPane extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FutureBuilder<List<PomodoroSessionRow>>(
      future: db.pomodoroDao.getCompletedFocusSessions(userId),
      builder: (context, snapshot) {
        final daily = groupPomodoroByDay(snapshot.data ?? const [], location);
        final today = LocalDate.fromInstant(DateTime.now().toUtc(), location);
        final weekStart = today.addDays(-(today.weekday - 1));
        final monthStart = LocalDate(today.year, today.month, 1);
        final todayStat = aggregatePomodoroPeriod(daily, periodStart: today, periodEnd: today);
        final weekStat =
            aggregatePomodoroPeriod(daily, periodStart: weekStart, periodEnd: today);
        final monthStat =
            aggregatePomodoroPeriod(daily, periodStart: monthStart, periodEnd: today);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l10n.pomodoroStatsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _statRow(context, l10n.pomodoroStatsDaily, todayStat),
          _statRow(context, l10n.pomodoroStatsWeekly, weekStat),
          _statRow(context, l10n.pomodoroStatsMonthly, monthStat),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.pomodoroHistoryTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<List<PomodoroSessionRow>>(
            stream: db.pomodoroDao.watchRecent(userId, limit: 10),
            builder: (context, historySnap) {
              final rows = historySnap.data ?? const <PomodoroSessionRow>[];
              if (rows.isEmpty) {
                return Text(l10n.pomodoroHistoryEmpty,
                    style: Theme.of(context).textTheme.bodySmall);
              }
              return Column(
                  children: [for (final r in rows) _historyRow(context, r, l10n)]);
            },
          ),
        ]);
      },
    );
  }

  Widget _statRow(BuildContext context, String label, PomodoroPeriodStat stat) {
    final minutes = stat.totalActualSeconds ~/ 60;
    // A Column (not a Row) so a long value string or a large text-scale
    // factor never forces a horizontal overflow.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(l10n.pomodoroStatValue(minutes, stat.sessionCount)),
      ]),
    );
  }

  Widget _historyRow(BuildContext context, PomodoroSessionRow r, AppLocalizations l10n) {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(children: [
        SizedBox(width: 48, child: Text(timeLabel, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(child: Text('$jenisLabel · $statusLabel')),
        Text('${r.durasiMenit}m', style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
