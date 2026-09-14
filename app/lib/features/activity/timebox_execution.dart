/// In-memory Timebox execution state (actual start/end times).
///
/// The full schema gives Timebox occurrences dedicated `actual_start` /
/// `actual_end` columns and pending/completed/missed/rescheduled statuses, but
/// those are deferred past M1. To match design/preview/home.html's start-block →
/// complete-block flow without a schema migration, actual times are kept here in
/// memory, keyed by Activity id, and reset when the app restarts.
class TimeboxExecution {
  TimeboxExecution._();

  /// Process-wide store so state survives widget rebuilds and detail sheets.
  static final TimeboxExecution instance = TimeboxExecution._();

  final Map<String, DateTime> _actualStart = {};
  final Map<String, DateTime> _actualEnd = {};

  DateTime? actualStart(String activityId) => _actualStart[activityId];
  DateTime? actualEnd(String activityId) => _actualEnd[activityId];

  /// Whether a block has been started but not yet completed.
  bool isRunning(String activityId) =>
      _actualStart.containsKey(activityId) &&
      !_actualEnd.containsKey(activityId);

  void start(String activityId, DateTime now) => _actualStart[activityId] = now;

  void complete(String activityId, DateTime now) =>
      _actualEnd[activityId] = now;

  /// Clears any recorded actuals (e.g. when skipping/reopening a block).
  void reset(String activityId) {
    _actualStart.remove(activityId);
    _actualEnd.remove(activityId);
  }
}
