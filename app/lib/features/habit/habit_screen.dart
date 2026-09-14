import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/design_form.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/time/local_date.dart';
import '../../core/time/tz_data.dart';
import '../../l10n/app_localizations.dart';
import '../shell/tugas_shell.dart';
import 'habit_cubit.dart';
import 'habit_detail_screen.dart';
import 'habit_state.dart';

/// Locale-aware Mon..Sun abbreviations (mirrors
/// `features/activity/add_activity_sheet.dart`'s `_weekdayShortLabels`;
/// NFR-7: intl is the source of truth, not a hand-rolled id/en array).
List<String> weekdayShortLabels(BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  final fmt = DateFormat.E(locale);
  return List.generate(7, (i) => fmt.format(DateTime(2024, 1, 1 + i)));
}

const List<String> habitColorPresets = ['#4C6FFF', '#10B981', '#F59E0B'];

/// Habit tab (design/screens/habit.md; PRD 4.5 FR-5.*): Aktif/Dijeda tabs,
/// Hari-ini/Habit-lainnya split, quick checklist, add/edit/pause/reorder/
/// delete.
class HabitScreen extends StatefulWidget {
  const HabitScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.deviceId,
  });

  final AppDatabase db;
  final String userId;
  final String deviceId;

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
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
        appBar: AppBar(title: Text(l10n.navHabit)),
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
      activeIndex: 4,
      child: BlocBuilder<HabitCubit, HabitState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error == 'read') {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(l10n.habitReadFailed),
              TextButton(onPressed: cubit.retry, child: Text(l10n.actionRetry))
            ]));
          }
          return _HabitListBody(
              cubit: cubit,
              state: state,
              db: widget.db,
              userId: widget.userId,
              l10n: l10n);
        },
      ),
    );
  }
}

class _HabitListBody extends StatefulWidget {
  const _HabitListBody(
      {required this.cubit,
      required this.state,
      required this.db,
      required this.userId,
      required this.l10n});
  final HabitCubit cubit;
  final HabitState state;
  final AppDatabase db;
  final String userId;
  final AppLocalizations l10n;

  @override
  State<_HabitListBody> createState() => _HabitListBodyState();
}

class _HabitListBodyState extends State<_HabitListBody> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final mobile = MediaQuery.sizeOf(context).width <= 680;
    final items = widget.state.items;
    final activeItems = items.where((i) => !i.habit.isArchived).toList();
    final pausedItems = items.where((i) => i.habit.isArchived).toList();
    final shown = _tab == 0 ? activeItems : pausedItems;
    final today =
        shown.where((i) => _tab == 0 && i.isTargetToday).toList();
    final others = _tab == 0
        ? activeItems.where((i) => !i.isTargetToday).toList()
        : pausedItems;

    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: mobile ? 16 : 32, vertical: mobile ? 22 : 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Text(l10n.navHabit,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: mobile ? 28 : 30)),
                FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.habitAdd),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => Dialog(
                            child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 480),
                                child: HabitFormModal(cubit: widget.cubit))))),
              ]),
          const SizedBox(height: 20),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 0, label: Text(l10n.habitTabActive)),
              ButtonSegment(value: 1, label: Text(l10n.habitTabPaused)),
            ],
            selected: {_tab},
            onSelectionChanged: (v) => setState(() => _tab = v.first),
          ),
          const SizedBox(height: 20),
          if (widget.state.error == 'save')
            Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(l10n.habitSaveFailed,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          if (shown.isEmpty)
            Text(_tab == 0 ? l10n.habitEmptyActive : l10n.habitEmptyPaused,
                style: Theme.of(context).textTheme.bodySmall)
          else ...[
            if (_tab == 0) ...[
              Text(l10n.habitSectionToday,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              if (today.isEmpty)
                Text(l10n.habitEmptyActive,
                    style: Theme.of(context).textTheme.bodySmall)
              else
                for (final item in today)
                  _HabitRow(
                      item: item,
                      cubit: widget.cubit,
                      db: widget.db,
                      userId: widget.userId,
                      l10n: l10n,
                      allItems: items),
              const SizedBox(height: AppSpacing.xl),
              Text(l10n.habitSectionOthers,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              if (others.isEmpty)
                Text(l10n.habitEmptyActive,
                    style: Theme.of(context).textTheme.bodySmall)
              else
                for (final item in others)
                  _HabitRow(
                      item: item,
                      cubit: widget.cubit,
                      db: widget.db,
                      userId: widget.userId,
                      l10n: l10n,
                      allItems: items),
            ] else
              for (final item in others)
                _HabitRow(
                    item: item,
                    cubit: widget.cubit,
                    db: widget.db,
                    userId: widget.userId,
                    l10n: l10n,
                    allItems: items),
          ],
        ]));
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.item,
    required this.cubit,
    required this.db,
    required this.userId,
    required this.l10n,
    required this.allItems,
  });

  final HabitListItem item;
  final HabitCubit cubit;
  final AppDatabase db;
  final String userId;
  final AppLocalizations l10n;
  final List<HabitListItem> allItems;

  Color _color() {
    final hex = item.habit.warna.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width <= 680;
    final done = item.logToday?.status == HabitLogStatus.done;
    final index = allItems.indexWhere((i) => i.habit.id == item.habit.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => HabitDetailScreen(
                db: db, userId: userId, habitId: item.habit.id))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: _color(), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(item.habit.nama,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600))),
              if (item.isTargetToday)
                IconButton(
                  tooltip: l10n.habitStatusDone,
                  icon: Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: done
                          ? Theme.of(context).colorScheme.primary
                          : null),
                  onPressed: () {
                    if (done) {
                      showDialog(
                          context: context,
                          builder: (_) => Dialog(
                              child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 440),
                                  child: HabitLogModal(
                                      cubit: cubit,
                                      habitId: item.habit.id,
                                      tanggal: cubit.today,
                                      existing: item.logToday,
                                      remainingIzin:
                                          item.remainingIzinThisWeek))));
                    } else {
                      cubit.setLog(
                          habitId: item.habit.id,
                          status: HabitLogStatus.done);
                    }
                  },
                ),
              IconButton(
                  tooltip: l10n.habitLogTitle,
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: HabitLogModal(
                                  cubit: cubit,
                                  habitId: item.habit.id,
                                  tanggal: cubit.today,
                                  existing: item.logToday,
                                  remainingIzin:
                                      item.remainingIzinThisWeek))))),
              if (!mobile) ...[
                IconButton(
                    tooltip: l10n.habitMoveUp,
                    icon: const Icon(Icons.arrow_upward, size: 18),
                    onPressed: index <= 0
                        ? null
                        : () => _swap(index, index - 1)),
                IconButton(
                    tooltip: l10n.habitMoveDown,
                    icon: const Icon(Icons.arrow_downward, size: 18),
                    onPressed: index >= allItems.length - 1
                        ? null
                        : () => _swap(index, index + 1)),
              ],
            ]),
            const SizedBox(height: 4),
            Text(
                l10n.habitStreak(item.habit.currentStreak) +
                    (item.isTargetToday
                        ? ' · ${l10n.habitRemainingIzin(item.remainingIzinThisWeek)}'
                        : ''),
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }

  void _swap(int a, int b) {
    final ids = allItems.map((i) => i.habit.id).toList();
    final tmp = ids[a];
    ids[a] = ids[b];
    ids[b] = tmp;
    cubit.reorder(ids);
  }
}

class HabitFormModal extends StatefulWidget {
  const HabitFormModal({super.key, required this.cubit, this.existing});
  final HabitCubit cubit;
  final HabitListItem? existing;

  @override
  State<HabitFormModal> createState() => _HabitFormModalState();
}

class _HabitFormModalState extends State<HabitFormModal> {
  late final TextEditingController _nama;
  late String _warna;
  late Set<int> _targetHari;
  late int _quota;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nama = TextEditingController(text: existing?.habit.nama ?? '');
    _warna = existing?.habit.warna ?? habitColorPresets.first;
    _targetHari = existing?.scheduleToday?.targetHari.toSet() ?? {1, 3, 5};
    _quota = existing?.scheduleToday?.maxIzinPerMinggu ?? 1;
  }

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = weekdayShortLabels(context);
    return DesignModal(
      title: widget.existing == null ? l10n.habitAddTitle : l10n.habitEditTitle,
      saveLabel: l10n.tugasSave,
      busy: _saving,
      onSave: _submit,
      children: [
        DesignField(
            label: l10n.habitFieldName,
            child: TextField(
                controller: _nama,
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration())),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.habitFieldColor,
            child: Wrap(
                spacing: 10,
                children: [
                  for (final hex in habitColorPresets)
                    InkWell(
                      onTap: () => setState(() => _warna = hex),
                      child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: Color(
                                  int.parse('FF${hex.replaceFirst('#', '')}',
                                      radix: 16)),
                              shape: BoxShape.circle,
                              border: _warna == hex
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      width: 2)
                                  : null)),
                    ),
                ])),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.habitFieldTargetDays,
            child: Wrap(
                spacing: AppSpacing.sm,
                children: List.generate(7, (i) {
                  final weekday = i + 1;
                  final selected = _targetHari.contains(weekday);
                  return FilterChip(
                    label: Text(labels[i]),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _targetHari.add(weekday);
                      } else {
                        _targetHari.remove(weekday);
                      }
                    }),
                  );
                }))),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.habitFieldQuota,
            child: Row(children: [
              IconButton(
                  onPressed: _quota <= 0
                      ? null
                      : () => setState(() => _quota -= 1),
                  icon: const Icon(Icons.remove)),
              Text('$_quota', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                  onPressed: () => setState(() => _quota += 1),
                  icon: const Icon(Icons.add)),
            ])),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final nama = _nama.text.trim();
    if (nama.isEmpty) {
      setState(() => _error = l10n.habitNameRequired);
      return;
    }
    if (_targetHari.isEmpty) {
      setState(() => _error = l10n.habitTargetDaysRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.existing == null) {
        await widget.cubit.create(
            nama: nama,
            warna: _warna,
            targetHari: _targetHari,
            maxIzinPerMinggu: _quota);
      } else {
        final id = widget.existing!.habit.id;
        await widget.cubit.updateDefinition(id, nama: nama, warna: _warna);
        await widget.cubit.updateSchedule(id,
            targetHari: _targetHari, maxIzinPerMinggu: _quota);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.habitSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class HabitLogModal extends StatefulWidget {
  const HabitLogModal({
    super.key,
    required this.cubit,
    required this.habitId,
    required this.tanggal,
    required this.existing,
    required this.remainingIzin,
  });

  final HabitCubit cubit;
  final String habitId;
  final LocalDate tanggal;
  final HabitLogRow? existing;
  final int remainingIzin;

  @override
  State<HabitLogModal> createState() => _HabitLogModalState();
}

class _HabitLogModalState extends State<HabitLogModal> {
  late HabitLogStatus _status;
  late final TextEditingController _catatan;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _status = widget.existing?.status ?? HabitLogStatus.done;
    _catatan = TextEditingController(text: widget.existing?.catatan ?? '');
  }

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSkip =
        widget.remainingIzin > 0 || widget.existing?.status == HabitLogStatus.skip;
    return DesignModal(
      title: '${l10n.habitLogTitle} · ${widget.tanggal.toYmd()}',
      saveLabel: l10n.tugasSave,
      busy: _saving,
      onSave: _submit,
      children: [
        SegmentedButton<HabitLogStatus>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
                value: HabitLogStatus.done, label: Text(l10n.habitStatusDone)),
            ButtonSegment(
                value: HabitLogStatus.skip,
                enabled: canSkip,
                label: Text(l10n.habitStatusSkip)),
            ButtonSegment(
                value: HabitLogStatus.missed,
                label: Text(l10n.habitStatusMissed)),
          ],
          selected: {_status},
          onSelectionChanged: (v) => setState(() => _status = v.first),
        ),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.habitLogNote,
            child: TextField(
                controller: _catatan, maxLines: 3, decoration: const InputDecoration())),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final catatan = _catatan.text.trim();
      await widget.cubit.setLog(
          habitId: widget.habitId,
          tanggal: widget.tanggal,
          status: _status,
          catatan: catatan.isEmpty ? null : catatan);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.habitSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
