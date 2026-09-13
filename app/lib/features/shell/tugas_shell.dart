import 'package:flutter/material.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_screen.dart';

class TugasShell extends StatelessWidget {
  const TugasShell(
      {super.key,
      required this.db,
      required this.userId,
      required this.deviceId,
      required this.child});
  final AppDatabase db;
  final String userId;
  final String deviceId;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final l10n = AppLocalizations.of(context)!;
        final colors = Theme.of(context).colorScheme;
        final mobile = constraints.maxWidth <= 680;
        final compact = constraints.maxWidth <= 860;
        final items = [
          (Icons.home_outlined, l10n.homeTitle),
          (Icons.assignment_outlined, l10n.tugasTitle),
          (Icons.timer_outlined, 'Pomodoro'),
          (Icons.account_balance_wallet_outlined, l10n.navFinance),
          (Icons.checklist, l10n.navHabit)
        ];
        Widget item(int i) => Tooltip(
            message: i > 1 ? l10n.featureUnavailable : items[i].$2,
            child: TextButton(
              onPressed: i == 0
                  ? () =>
                      Navigator.of(context).popUntil((route) => route.isFirst)
                  : i == 1
                      ? () {}
                      : null,
              style: TextButton.styleFrom(
                  backgroundColor:
                      i == 1 ? colors.primaryContainer : Colors.transparent,
                  foregroundColor: i == 1 ? colors.primary : colors.onSurface,
                  padding: EdgeInsets.symmetric(
                      horizontal: mobile || compact ? 2 : 12, vertical: 12)),
              child: mobile || compact
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(items[i].$1, size: 20),
                      if (mobile)
                        Text(items[i].$2, style: const TextStyle(fontSize: 11))
                    ])
                  : Row(children: [
                      Icon(items[i].$1, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(items[i].$2))
                    ]),
            ));
        return Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 68,
              backgroundColor: colors.surface,
              shape: Border(bottom: BorderSide(color: colors.outlineVariant)),
              title: Text(l10n.appWordmark,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                                db: db, userId: userId, deviceId: deviceId))),
                    child: Text(l10n.settingsTitle)),
                const SizedBox(width: 16)
              ]),
          bottomNavigationBar: mobile
              ? SafeArea(
                  child: Container(
                      decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border(
                              top: BorderSide(color: colors.outlineVariant))),
                      child: Row(
                          children: List.generate(
                              5, (i) => Expanded(child: item(i))))))
              : null,
          body: Row(children: [
            if (!mobile)
              Container(
                  width: compact
                      ? 88
                      : constraints.maxWidth >= 1150
                          ? 166
                          : 142,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(color: colors.outlineVariant))),
                  child: Column(children: [
                    for (var i = 0; i < 5; i++) ...[
                      item(i),
                      const SizedBox(height: 8)
                    ]
                  ])),
            Expanded(child: child),
          ]),
        );
      });
}
