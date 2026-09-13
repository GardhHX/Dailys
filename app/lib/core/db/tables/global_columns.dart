import 'package:drift/drift.dart';

/// Global columns shared by every synced entity (schema Section 2).
///
/// These exist since M1 for M2 forward-compat even though sync is not yet active.
/// [TombstoneColumns] carries the id + audit + soft-delete + revision fields;
/// [OriginColumn] adds `origin_device_id`, which `User` deliberately omits
/// ("global columns tanpa `origin_device_id`", schema 3).
///
/// `id` is a UUID string (36 chars, lowercase canonical). Instants are stored as
/// integer-backed [DateTime] (schema Section 1). Local date / Local time columns
/// are stored as `TEXT` in their wire form (`YYYY-MM-DD` / `HH:mm:ss`) on the
/// individual tables so they stay unambiguous and timezone-free.
mixin TombstoneColumns on Table {
  /// Primary key; client can mint the UUID while offline.
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// Creation time from the origin device (Instant, UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft-delete flag; deletes use a tombstone.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Set when [isDeleted] is true; null while the row is active.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  IntColumn get serverRevision => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// `origin_device_id`: the device that produced the last mutation. Persistence
/// metadata, never sent to the client (schema Section 2).
mixin OriginColumn on Table {
  TextColumn get originDeviceId => text().withLength(min: 36, max: 36).nullable()();
}
