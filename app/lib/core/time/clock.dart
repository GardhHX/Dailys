/// Source of the current Instant (UTC). Schema.md stores all instants in UTC
/// (Section 1/2); this indirection lets tests and future recovery-timer logic
/// (OPERATIONS 7.3, NFR-13) inject a fixed or monotonic clock instead of
/// `DateTime.now()` directly.
abstract class Clock {
  DateTime nowUtc();
}

/// Default [Clock] backed by the system wall clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
