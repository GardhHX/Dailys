/// A schedule candidate for overlap detection (schema.md 14.1 "Overlap").
///
/// Only Activity participates in M1 (`TimeboxExecution` is M3); candidates
/// must already be filtered by the caller to active, non-`dilewati`,
/// non-all-day/flexible entries with both `start`/`end` set.
class ScheduleInterval {
  const ScheduleInterval({
    required this.entityType,
    required this.entityId,
    required this.start,
    required this.end,
  });

  final String entityType;
  final String entityId;

  /// Half-open `[start, end)` in Instant UTC.
  final DateTime start;
  final DateTime end;

  /// `(entityType, entityId)` lexicographic key used to pick the "left" side
  /// of a pair deterministically (schema 14.1).
  String get _key => '$entityType:$entityId';
}

/// A non-blocking `SCHEDULE_OVERLAP` warning between two candidates.
class OverlapWarning {
  const OverlapWarning({
    required this.left,
    required this.right,
    required this.overlapStart,
    required this.overlapEnd,
  });

  final ScheduleInterval left;
  final ScheduleInterval right;
  final DateTime overlapStart;
  final DateTime overlapEnd;
}

/// Finds all pairwise overlaps among [candidates] (schema.md 14.1 "Overlap").
///
/// Interval `[start, end)` is half-open, so a block ending exactly when
/// another starts does not overlap. Two intervals overlap iff
/// `max(start_a, start_b) < min(end_a, end_b)`. The lexicographically smaller
/// `(entityType, entityId)` is always `left`; results are sorted by
/// `overlap_start`, then left key, then right key, with duplicate pairs
/// removed.
List<OverlapWarning> findOverlaps(List<ScheduleInterval> candidates) {
  final warnings = <OverlapWarning>[];
  for (var i = 0; i < candidates.length; i++) {
    for (var j = i + 1; j < candidates.length; j++) {
      final a = candidates[i];
      final b = candidates[j];
      final overlapStart = a.start.isAfter(b.start) ? a.start : b.start;
      final overlapEnd = a.end.isBefore(b.end) ? a.end : b.end;
      if (overlapStart.isBefore(overlapEnd)) {
        final aIsLeft = a._key.compareTo(b._key) <= 0;
        warnings.add(OverlapWarning(
          left: aIsLeft ? a : b,
          right: aIsLeft ? b : a,
          overlapStart: overlapStart,
          overlapEnd: overlapEnd,
        ));
      }
    }
  }

  warnings.sort((x, y) {
    final byStart = x.overlapStart.compareTo(y.overlapStart);
    if (byStart != 0) return byStart;
    final byLeft = x.left._key.compareTo(y.left._key);
    if (byLeft != 0) return byLeft;
    return x.right._key.compareTo(y.right._key);
  });
  return warnings;
}
