import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registered before runApp so Splash/Onboarding/Settings can update them the
  // moment local preferences are known (see [[dailys-repo-and-m1-stack]] for
  // why theme/locale must never wait on network).
  locator.registerSingleton<ValueNotifier<ThemeMode>>(ValueNotifier(ThemeMode.system));
  locator.registerSingleton<ValueNotifier<Locale?>>(ValueNotifier(null));

  runApp(DailysApp(
    themeModeNotifier: locator<ValueNotifier<ThemeMode>>(),
    localeNotifier: locator<ValueNotifier<Locale?>>(),
  ));
}
