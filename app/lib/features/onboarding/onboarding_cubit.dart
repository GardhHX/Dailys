import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show Locale, ValueNotifier;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/di/locator.dart';
import '../../core/time/tz_data.dart';
import 'onboarding_state.dart';

/// Drives the first-run onboarding flow's language/timezone step and
/// completion (design/screens/onboarding.md stages 1 and 4).
///
/// Local-first: nothing here waits on the network (schema 3.1 UserSettings is
/// synced later, at M2; `DeviceSettings.onboarding_completed_at` is local-only
/// per schema 3.2 and is what Splash checks to route past onboarding).
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required AppDatabase db,
    required String userId,
    required String deviceId,
  })  : _db = db,
        _userId = userId,
        _deviceId = deviceId,
        super(OnboardingState(
          language: Language.id,
          timezone: 'Asia/Jakarta',
          availableTimezones: _loadTimezoneNames(),
        ));

  final AppDatabase _db;
  final String _userId;
  final String _deviceId;

  static List<String> _loadTimezoneNames() {
    ensureTimeZoneDatabaseLoaded();
    final names = tz.timeZoneDatabase.locations.keys.toList()..sort();
    return names;
  }

  void selectLanguage(Language language) => emit(state.copyWith(language: language));

  void selectTimezone(String timezone) => emit(state.copyWith(timezone: timezone));

  /// Persists the chosen language/timezone to `UserSettings` and marks local
  /// onboarding complete — completion never waits for server registration
  /// (design spec: "Completion membuka Today tanpa menunggu VPS").
  Future<void> finish() async {
    emit(state.copyWith(saving: true, error: null));
    try {
      await _db.settingsDao.updateUserSettings(
        _userId,
        UserSettingsCompanion(
          language: Value(state.language),
          timezone: Value(state.timezone),
        ),
      );
      await _db.settingsDao.markOnboardingCompleted(_deviceId);
      if (locator.isRegistered<ValueNotifier<Locale?>>()) {
        locator<ValueNotifier<Locale?>>().value = Locale(state.language.name);
      }
      emit(state.copyWith(saving: false, completed: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
