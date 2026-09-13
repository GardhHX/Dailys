/// Daily completion rate (schema.md 14.1 "Daily completion rate").
///
/// For a Local date `D`, `planned` is every active (`is_deleted=false`)
/// Activity with `occurrence_date=D` — all-day, flexible, recurring, and
/// derived Activity all count, and every status counts, including
/// `dilewati`. `completed` counts only `status=selesai`.
///
/// `rate_percent = planned == 0 ? 0.0 : round_half_up(100 * completed / planned, 1)`
///
/// Dart's [double.round] already rounds ties away from zero, which for this
/// always-non-negative ratio is exactly `round_half_up`.
double completionRatePercent({required int completed, required int planned}) {
  if (planned == 0) return 0.0;
  final raw = 100 * completed / planned;
  return (raw * 10).round() / 10;
}
