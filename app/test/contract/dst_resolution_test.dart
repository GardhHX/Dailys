import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:dailys/core/time/tz_resolver.dart';

// Golden vectors from schema.md 23.1 (America/New_York, 2026).
// DST starts 2026-03-08 (02:00 EST -> 03:00 EDT); ends 2026-11-01
// (02:00 EDT -> 01:00 EST). EST = UTC-5, EDT = UTC-4.
void main() {
  late tz.Location ny;

  setUpAll(() {
    tzdata.initializeTimeZones();
    ny = tz.getLocation('America/New_York');
  });

  String u(int y, int mo, int d, int h, int mi) =>
      TzResolver.toContractUtc(TzResolver.localToUtc(ny, y, mo, d, h, mi));

  group('DST resolution (schema.md 23.1)', () {
    test('normal EDT day: 02:30 -> 06:30Z', () {
      expect(u(2026, 3, 9, 2, 30), '2026-03-09T06:30:00Z');
    });

    test('spring-forward gap: 02:30 clamps to 03:00 EDT -> 07:00Z', () {
      expect(u(2026, 3, 8, 2, 30), '2026-03-08T07:00:00Z');
    });

    test('normal EST day: 02:30 -> 07:30Z', () {
      expect(u(2026, 11, 2, 2, 30), '2026-11-02T07:30:00Z');
    });

    test('fall-back ambiguous: 01:30 -> earlier EDT occurrence 05:30Z', () {
      expect(u(2026, 11, 1, 1, 30), '2026-11-01T05:30:00Z');
    });
  });
}
