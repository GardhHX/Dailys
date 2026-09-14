import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// In-memory Habits sidebar panel mirroring `design/preview/home.html`
/// (`dh-habitrow`). The Habit/HabitLog tables are deferred past M1, so this
/// keeps its state in memory only — seeded with the reference's sample habits so
/// the panel reads like the design. State resets when the app restarts.
class HabitsPanel extends StatefulWidget {
  const HabitsPanel({
    super.key,
    required this.activeDate,
    required this.isToday,
    required this.locale,
  });

  /// The date currently selected on Home (local).
  final DateTime activeDate;

  /// Whether [activeDate] is today — habits are only checkable for today,
  /// matching the reference.
  final bool isToday;
  final String locale;

  @override
  State<HabitsPanel> createState() => _HabitsPanelState();
}

class _Habit {
  _Habit({required this.name, required this.days, required this.baseStreak});

  final String name;

  /// Weekday integers 1..7 (Mon..Sun) the habit is due on.
  final List<int> days;
  final int baseStreak;

  /// Per-date log keyed by `YYYY-MM-DD`: 'done' or 'skip'.
  final Map<String, String> logs = {};
}

class _HabitsPanelState extends State<HabitsPanel> {
  late final List<_Habit> _habits = [
    _Habit(name: 'Baca 10 halaman', days: const [1, 2, 3, 4, 5, 6, 7], baseStreak: 5),
    _Habit(name: 'Jalan kaki 20 menit', days: const [2, 4, 6], baseStreak: 3),
    _Habit(name: 'Review materi 15 menit', days: const [1, 2, 3, 4, 5, 6], baseStreak: 4),
  ];

  String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime get _today => DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final weekday = widget.activeDate.weekday; // 1..7
    final eligible = _habits.where((h) => h.days.contains(weekday)).toList();
    final dateKey = _key(widget.activeDate);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(l10n.homeHabits, style: theme.textTheme.titleMedium)),
        Text(
            widget.isToday
                ? l10n.activityToday
                : DateFormat.MMMd(widget.locale).format(widget.activeDate),
            style: theme.textTheme.bodySmall),
      ]),
      const SizedBox(height: 16),
      if (eligible.isEmpty)
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.homeNoDeadlines,
                    style: theme.textTheme.bodySmall)))
      else
        for (final h in eligible) _row(context, h, dateKey, l10n),
      const SizedBox(height: AppSpacing.sm),
      Text(l10n.habitDemoNote,
          style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
    ]);
  }

  Widget _row(
      BuildContext context, _Habit h, String dateKey, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = h.logs[dateKey];
    final done = status == 'done';
    final streak = h.baseStreak + (h.logs[_key(_today)] == 'done' ? 1 : 0);
    final statusLabel = done
        ? l10n.activityStatusSelesai
        : status == 'skip'
            ? l10n.habitSkipped
            : l10n.habitNotDone;
    final daysLabel = h.days.length == 7
        ? l10n.habitEveryDay
        : h.days.map(_shortWeekday).join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.outlineVariant))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Checkbox(
            value: done,
            onChanged: widget.isToday
                ? (v) => setState(() {
                      if (v ?? false) {
                        h.logs[dateKey] = 'done';
                      } else {
                        h.logs.remove(dateKey);
                      }
                    })
                : null,
          ),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.name,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 4),
            Text('$statusLabel · $daysLabel',
                style: theme.textTheme.labelSmall),
            const SizedBox(height: 5),
            Text(l10n.habitStreak(streak),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: _successColor(theme))),
          ]),
        ),
      ]),
    );
  }

  /// The tokens' `success` role isn't in ColorScheme; derive it from brightness
  /// to match design/tokens.json (light #266044 / dark #a2dfbb).
  Color _successColor(ThemeData theme) => theme.brightness == Brightness.dark
      ? const Color(0xffa2dfbb)
      : const Color(0xff266044);

  String _shortWeekday(int weekday) {
    // Anchor on a known Monday (2024-01-01) and offset to the weekday.
    final d = DateTime(2024, 1, 1).add(Duration(days: weekday - 1));
    return DateFormat.E(widget.locale).format(d);
  }
}
