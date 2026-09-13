import 'package:uuid/uuid.dart';

/// Deterministic and random ID generation.
///
/// Ordinary offline-created resources use UUIDv4. Entities representing a single
/// logical event use UUIDv5 so two devices produce the same id (schema.md
/// "Deterministic IDs" and API-SPEC 8.2). UUIDv5 uses the standard URL namespace
/// and lowercase canonical names.
class DeterministicId {
  DeterministicId._();

  /// Standard URL namespace UUID (schema.md "Deterministic IDs").
  static const String urlNamespace = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';

  static const Uuid _uuid = Uuid();

  /// Random UUIDv4 for ordinary offline-created resources.
  static String v4() => _uuid.v4();

  /// UUIDv5 of [canonicalName] under the URL namespace.
  static String v5(String canonicalName) => _uuid.v5(urlNamespace, canonicalName);

  // --- Canonical names (schema.md "Deterministic IDs" / API-SPEC 8.2) ---

  static String seedActivityCategory(String userId, String slug) =>
      v5('urn:dailys:v1.0:activity-category:$userId:$slug');

  static String seedFinanceCategory(String userId, String tipe, String slug) =>
      v5('urn:dailys:v1.0:finance-category:$userId:$tipe:$slug');

  /// [ymd] is the log's local date, YYYY-MM-DD.
  static String habitLog(String habitId, String ymd) =>
      v5('urn:dailys:v1.0:habit-log:$habitId:$ymd');

  /// [plannedStartAtUtc] is RFC 3339 second precision, e.g. 2026-03-08T07:00:00Z.
  static String timeboxExecution(String scheduleId, String plannedStartAtUtc) =>
      v5('urn:dailys:v1.0:timebox-execution:$scheduleId:$plannedStartAtUtc');

  static String habitSchedule(String habitId, String effectiveFrom) =>
      v5('urn:dailys:v1.0:habit-schedule:$habitId:$effectiveFrom');

  static String userSettings(String userId) =>
      v5('urn:dailys:v1.0:user-settings:$userId');

  static String recurringActivity(String recurrenceId, String ymd) =>
      v5('urn:dailys:v1.0:activity-occurrence:$recurrenceId:$ymd');

  static String derivedActivity(String source, String sourceId) =>
      v5('urn:dailys:v1.0:derived-activity:$source:$sourceId');

  static String weeklyReview(String userId, String weekStart) =>
      v5('urn:dailys:v1.0:weekly-review:$userId:$weekStart');

  static String weeklyPlanPromotion(String draftId, String targetType) =>
      v5('urn:dailys:v1.0:weekly-plan-promotion:$draftId:$targetType');
}
