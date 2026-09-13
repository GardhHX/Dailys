import 'package:dailys/core/projections/completion_rate.dart';
import 'package:flutter_test/flutter_test.dart';

// Fixtures from schema.md 14.1 "Daily completion rate".
void main() {
  test('no active Activity on D -> planned=0, completed=0, rate=0.0', () {
    expect(completionRatePercent(completed: 0, planned: 0), 0.0);
  });

  test('mixed: selesai/dilewati/belum_mulai -> planned=3, completed=1, rate=33.3', () {
    expect(completionRatePercent(completed: 1, planned: 3), 33.3);
  });

  test('all completed -> 100.0', () {
    expect(completionRatePercent(completed: 4, planned: 4), 100.0);
  });

  test('rounds half up to one decimal', () {
    // 100 * 1/80 = 1.25 exactly -> the second decimal is a tie, rounded away
    // from zero (half-up) to 1.3, not down to 1.2.
    expect(completionRatePercent(completed: 1, planned: 80), 1.3);
    // 100 * 5/6 = 83.333... -> 83.3
    expect(completionRatePercent(completed: 5, planned: 6), 83.3);
    // 100 * 1/6 = 16.666... -> 16.7
    expect(completionRatePercent(completed: 1, planned: 6), 16.7);
  });
}
