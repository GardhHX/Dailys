import '../../core/db/tables/enums.dart';

/// First-run onboarding state. M1 only covers stage 1 ("Bahasa & waktu") and
/// stage 4 ("Ringkasan & mulai") of design/screens/onboarding.md — stage 2
/// (device registration) needs sync (M2) and stage 3 (akun pertama) needs
/// Keuangan (M4), so both are out of scope until those milestones land.
class OnboardingState {
  const OnboardingState({
    required this.language,
    required this.timezone,
    required this.availableTimezones,
    this.saving = false,
    this.completed = false,
    this.error,
  });

  final Language language;
  final String timezone;
  final List<String> availableTimezones;
  final bool saving;
  final bool completed;
  final String? error;

  OnboardingState copyWith({
    Language? language,
    String? timezone,
    bool? saving,
    bool? completed,
    String? error,
  }) =>
      OnboardingState(
        language: language ?? this.language,
        timezone: timezone ?? this.timezone,
        availableTimezones: availableTimezones,
        saving: saving ?? this.saving,
        completed: completed ?? this.completed,
        error: error,
      );
}
