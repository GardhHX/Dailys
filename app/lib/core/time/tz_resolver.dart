import 'package:timezone/timezone.dart' as tz;

/// Converts a local wall-clock time in an IANA zone to a UTC instant, applying
/// Dailys' explicit DST policy (schema.md 2 and 23.1):
///
///  - nonexistent local time (spring-forward gap): clamp to the first valid
///    instant after the gap. This is deliberately NOT "shift by the gap length";
///    default resolvers (java.time, Temporal, and similar) usually shift, so do
///    not rely on library defaults.
///  - ambiguous local time (fall-back): choose the earlier occurrence.
class TzResolver {
  TzResolver._();

  /// Resolve the given local wall clock in [location] to a UTC [DateTime].
  static DateTime localToUtc(
    tz.Location location,
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
    int second = 0,
  ]) {
    final naive =
        DateTime.utc(year, month, day, hour, minute, second).millisecondsSinceEpoch;

    int offsetAt(int utcMs) => location.timeZone(utcMs).offset;
    bool valid(int utcMs) => offsetAt(utcMs) == naive - utcMs;

    final utcA = naive - offsetAt(naive);
    final utcB = naive - offsetAt(utcA);
    final validA = valid(utcA);
    final validB = valid(utcB);

    if (validA && validB) {
      // Ambiguous (fall-back): both map back to the requested wall clock.
      // Choose the earlier occurrence.
      final earlier = utcA < utcB ? utcA : utcB;
      return DateTime.fromMillisecondsSinceEpoch(earlier, isUtc: true);
    }
    if (validA) return DateTime.fromMillisecondsSinceEpoch(utcA, isUtc: true);
    if (validB) return DateTime.fromMillisecondsSinceEpoch(utcB, isUtc: true);

    // Gap (spring-forward): neither candidate is valid. Clamp to the transition
    // instant, i.e. the first valid instant after the gap.
    var lo = utcA < utcB ? utcA : utcB;
    var hi = utcA < utcB ? utcB : utcA;
    final offLo = offsetAt(lo);
    while (hi - lo > 1) {
      final mid = lo + ((hi - lo) >> 1);
      if (offsetAt(mid) == offLo) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(hi, isUtc: true);
  }

  /// RFC 3339 UTC with second precision and no fractional seconds, e.g.
  /// `2026-03-08T07:00:00Z` (schema.md planned_start_at_utc form).
  static String toContractUtc(DateTime instant) {
    final d = instant.toUtc();
    String p2(int n) => n.toString().padLeft(2, '0');
    final y = d.year.toString().padLeft(4, '0');
    return '$y-${p2(d.month)}-${p2(d.day)}T${p2(d.hour)}:${p2(d.minute)}:${p2(d.second)}Z';
  }
}
