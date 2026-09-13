import 'package:timezone/timezone.dart' as tz;

/// A calendar date with no time-of-day or timezone component (schema.md
/// Section 1: "Local date"). Stored on disk/wire as its canonical `YYYY-MM-DD`
/// string; arithmetic here never touches an [Instant] or a UTC offset.
///
/// Used for fields like `occurrence_date`, `starts_on`/`ends_on`, `tanggal`,
/// and for materializer date-range walking (schema Section 2).
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Parses a canonical `YYYY-MM-DD` string.
  factory LocalDate.parse(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) {
      throw FormatException('not a YYYY-MM-DD local date: $ymd');
    }
    return LocalDate(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  /// The Local date of [instant] as observed in [location] — used to derive
  /// "today" for a given user timezone (schema Section 2, 23.2).
  factory LocalDate.fromInstant(DateTime instant, tz.Location location) {
    final local = tz.TZDateTime.from(instant, location);
    return LocalDate(local.year, local.month, local.day);
  }

  /// ISO-8601 weekday: 1 = Monday ... 7 = Sunday. Matches the `recurring_days` /
  /// `target_hari` wire convention (schema 7, 11.1 golden table).
  int get weekday => DateTime.utc(year, month, day).weekday;

  LocalDate addDays(int days) {
    final d = DateTime.utc(year, month, day).add(Duration(days: days));
    return LocalDate(d.year, d.month, d.day);
  }

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  /// Canonical wire form, `YYYY-MM-DD`.
  String toYmd() {
    String p(int n, int width) => n.toString().padLeft(width, '0');
    return '${p(year, 4)}-${p(month, 2)}-${p(day, 2)}';
  }

  @override
  String toString() => toYmd();

  @override
  int compareTo(LocalDate other) => toYmd().compareTo(other.toYmd());

  @override
  bool operator ==(Object other) =>
      other is LocalDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}
