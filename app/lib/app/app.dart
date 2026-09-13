import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root widget: `MaterialApp.router` wired to [buildAppRouter] and the id/en
/// localization resources (NFR-7). [themeModeNotifier] is updated by Splash
/// once `DeviceSettings.theme` is known, and live by Settings afterward.
class DailysApp extends StatelessWidget {
  const DailysApp({
    super.key,
    required this.themeModeNotifier,
    required this.localeNotifier,
  });

  final ValueNotifier<ThemeMode> themeModeNotifier;

  /// Null = follow system (pre-onboarding fallback, design/screens/splash.md
  /// "Teks ID/EN": "sebelumnya fallback localization aplikasi"). Set once
  /// `UserSettings.language` is known/changed so the resource language always
  /// follows the stored preference, not the OS locale (settings.md: "Perubahan
  /// bahasa menerapkan resource localization").
  final ValueNotifier<Locale?> localeNotifier;

  @override
  Widget build(BuildContext context) {
    final router = buildAppRouter();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) => ValueListenableBuilder<Locale?>(
        valueListenable: localeNotifier,
        builder: (context, locale, __) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appWordmark,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }
}
