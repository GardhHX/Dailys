import 'package:dailys/core/projections/overlap.dart';
import 'package:flutter_test/flutter_test.dart';

// Fixtures from schema.md 14.1 "Overlap".
void main() {
  DateTime t(int h, [int m = 0]) => DateTime.utc(2026, 9, 14, h, m);

  test('boundary interval: A [09:00,10:00) B [10:00,11:00) does not overlap', () {
    final a = ScheduleInterval(entityType: 'activity', entityId: 'a', start: t(9), end: t(10));
    final b = ScheduleInterval(entityType: 'activity', entityId: 'b', start: t(10), end: t(11));
    expect(findOverlaps([a, b]), isEmpty);
  });

  test('intersecting interval: A [09:00,10:30) B [10:00,11:00) overlaps [10:00,10:30)', () {
    final a = ScheduleInterval(entityType: 'activity', entityId: 'a', start: t(9), end: t(10, 30));
    final b = ScheduleInterval(entityType: 'activity', entityId: 'b', start: t(10), end: t(11));
    final warnings = findOverlaps([a, b]);
    expect(warnings, hasLength(1));
    expect(warnings.single.overlapStart, t(10));
    expect(warnings.single.overlapEnd, t(10, 30));
  });

  test('left is the lexicographically smaller (entityType, entityId)', () {
    final a = ScheduleInterval(entityType: 'activity', entityId: 'zzz', start: t(9), end: t(10, 30));
    final b = ScheduleInterval(entityType: 'activity', entityId: 'aaa', start: t(10), end: t(11));
    final warnings = findOverlaps([a, b]);
    expect(warnings.single.left.entityId, 'aaa');
    expect(warnings.single.right.entityId, 'zzz');
  });

  test('no false positive when intervals are disjoint', () {
    final a = ScheduleInterval(entityType: 'activity', entityId: 'a', start: t(9), end: t(10));
    final b = ScheduleInterval(entityType: 'activity', entityId: 'b', start: t(12), end: t(13));
    expect(findOverlaps([a, b]), isEmpty);
  });

  test('sorted by overlap_start, then left key, then right key', () {
    // Two independent overlapping pairs on the same day, second pair earlier.
    final a1 = ScheduleInterval(entityType: 'activity', entityId: 'a1', start: t(14), end: t(15));
    final a2 = ScheduleInterval(entityType: 'activity', entityId: 'a2', start: t(14, 30), end: t(15, 30));
    final b1 = ScheduleInterval(entityType: 'activity', entityId: 'b1', start: t(9), end: t(10));
    final b2 = ScheduleInterval(entityType: 'activity', entityId: 'b2', start: t(9, 30), end: t(10, 30));

    final warnings = findOverlaps([a1, a2, b1, b2]);
    expect(warnings, hasLength(2));
    expect(warnings.first.overlapStart, t(9, 30)); // earlier pair first
    expect(warnings.last.overlapStart, t(14, 30));
  });

  test('three-way overlap yields three pairwise warnings, no duplicates', () {
    final a = ScheduleInterval(entityType: 'activity', entityId: 'a', start: t(9), end: t(11));
    final b = ScheduleInterval(entityType: 'activity', entityId: 'b', start: t(10), end: t(12));
    final c = ScheduleInterval(entityType: 'activity', entityId: 'c', start: t(10, 30), end: t(11, 30));
    expect(findOverlaps([a, b, c]), hasLength(3));
  });
}
