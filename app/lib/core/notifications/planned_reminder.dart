/// One reminder instance ready to fire (FR-1.10, FR-6.4): a stable [id]
/// (derived from the owning row and the specific offset/rule, so editing one
/// reminder never disturbs another), the Instant it is due at, and the
/// already-localized text to show.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  final String id;
  final DateTime fireAt;
  final String title;
  final String body;
}
