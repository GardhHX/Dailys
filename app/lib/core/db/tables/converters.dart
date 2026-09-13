import 'dart:convert';

import 'package:drift/drift.dart';

/// JSON-array TypeConverters (schema Section 1: "JSON array | JSON text").
///
/// Stored as canonical JSON text so a device and the server produce byte-identical
/// payloads for hashing. Empty arrays are stored as `[]`, never null, for the
/// columns whose contract default is `[]`.

/// `List<int>` <-> JSON text. Used for `recurring_days`, `target_hari`, and
/// `reminder_offsets_minutes` (weekday/offset arrays of integers).
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).map((e) => e as int).toList(growable: false);

  @override
  String toSql(List<int> value) => jsonEncode(value);
}

/// `List<Map<String, Object?>>` <-> JSON text. Used for `Tugas.reminders`
/// (array of typed TaskReminder objects; schema 5).
class JsonMapListConverter
    extends TypeConverter<List<Map<String, Object?>>, String> {
  const JsonMapListConverter();

  @override
  List<Map<String, Object?>> fromSql(String fromDb) => (jsonDecode(fromDb) as List)
      .map((e) => (e as Map).cast<String, Object?>())
      .toList(growable: false);

  @override
  String toSql(List<Map<String, Object?>> value) => jsonEncode(value);
}
