import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/ids/deterministic_id.dart';
import '../../core/time/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../habit/habit_detail_screen.dart';

/// Home Habits companion panel (design/screens/home.md: "Habits (panel
/// pendamping) ... memakai sumber Habit normatif yang sama dengan tab
/// Habit", FR-5.2/5.3/5.13). Reads straight from `HabitDao` — the same
/// source the Habit tab uses — rather than the in-memory placeholder this
/// panel used before M4.
class HabitsPanel extends StatelessWidget {
  const HabitsPanel({
    super.key,
    required this.db,
    required this.userId,
    required this.activeDate,
    required this.location,
  });

  final AppDatabase db;
  final String userId;
  final LocalDate activeDate;
  final tz.Location location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l10n.homeHabits, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      StreamBuilder<List<HabitRow>>(
        stream: db.habitDao.watchHabits(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(l10n.habitReadFailed,
                style: Theme.of(context).textTheme.bodySmall);
          }
          final habits = (snapshot.data ?? const <HabitRow>[])
              .where((h) => !h.isArchived)
              .toList();
          if (habits.isEmpty) {
            return Text(l10n.habitEmptyActive,
                style: Theme.of(context).textTheme.bodySmall);
          }
          return FutureBuilder<List<_PanelItem>>(
            future: _buildItems(habits),
            builder: (context, itemsSnap) {
              final items = itemsSnap.data;
              if (items == null) {
                return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator());
              }
              final targets = items.where((i) => i.isTarget).toList();
              if (targets.isEmpty) {
                return Text(l10n.habitEmptyActive,
                    style: Theme.of(context).textTheme.bodySmall);
              }
              final today =
                  LocalDate.fromInstant(DateTime.now().toUtc(), location);
              final canCheck = !activeDate.isAfter(today);
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in targets)
                      _PanelRow(
                          db: db,
                          userId: userId,
                          item: item,
                          activeDate: activeDate,
                          today: today,
                          canCheck: canCheck,
                          l10n: l10n),
                  ]);
            },
          );
        },
      ),
    ]);
  }

  Future<List<_PanelItem>> _buildItems(List<HabitRow> habits) async {
    final items = <_PanelItem>[];
    for (final habit in habits) {
      final schedule = await db.habitDao.getScheduleForDate(habit.id, activeDate);
      final log = await db.habitDao.getLogForDate(habit.id, activeDate);
      final isTarget = schedule != null &&
          schedule.state == HabitScheduleState.active &&
          schedule.targetHari.contains(activeDate.weekday);
      items.add(_PanelItem(habit: habit, log: log, isTarget: isTarget));
    }
    return items;
  }
}

class _PanelItem {
  const _PanelItem({required this.habit, required this.log, required this.isTarget});
  final HabitRow habit;
  final HabitLogRow? log;
  final bool isTarget;
}

class _PanelRow extends StatelessWidget {
  const _PanelRow({
    required this.db,
    required this.userId,
    required this.item,
    required this.activeDate,
    required this.today,
    required this.canCheck,
    required this.l10n,
  });

  final AppDatabase db;
  final String userId;
  final _PanelItem item;
  final LocalDate activeDate;
  final LocalDate today;
  final bool canCheck;
  final AppLocalizations l10n;

  Color _color() {
    final hex = item.habit.warna.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final done = item.log?.status == HabitLogStatus.done;
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              HabitDetailScreen(db: db, userId: userId, habitId: item.habit.id))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: _color(), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(item.habit.nama,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis)),
          Text(l10n.habitStreak(item.habit.currentStreak),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color:
                    done ? Theme.of(context).colorScheme.primary : null),
            onPressed: !canCheck || done
                ? null
                : () => db.habitDao.upsertLog(
                      habitId: item.habit.id,
                      tanggal: activeDate,
                      status: HabitLogStatus.done,
                      activityCategoryId:
                          DeterministicId.seedActivityCategory(userId, 'personal'),
                      today: today,
                    ),
          ),
        ]),
      ),
    );
  }
}
