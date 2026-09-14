import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class HabitsPanel extends StatelessWidget {
  const HabitsPanel(
      {super.key,
      required this.activeDate,
      required this.isToday,
      required this.locale});
  final DateTime activeDate;
  final bool isToday;
  final String locale;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l10n.homeHabits, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 16),
      Text(l10n.homeHabitIntegrationGap,
          style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}
