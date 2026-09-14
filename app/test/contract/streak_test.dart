import 'package:flutter_test/flutter_test.dart';

/// Golden table from schema.md 11.3 "Algoritma streak normatif" (timezone
/// `Asia/Jakarta`). Habit/HabitSchedule/HabitLog land in M4; kept here (not
/// deleted) so the fixture isn't lost before the streak evaluator exists.
///
/// | Tanggal        | Schedule/state        | Log                          | current | longest |
/// |----------------|------------------------|-------------------------------|--------:|--------:|
/// | Sen 2026-09-07 | active `[1,3,5]`       | done                          |       1 |       1 |
/// | Rab 2026-09-09 | active `[1,3,5]`       | skip valid                    |       1 |       1 |
/// | Jum 2026-09-11 | active `[1,3,5]`       | done                          |       2 |       2 |
/// | Sen 2026-09-14 | active `[1,3,5]`       | none after day ends           |       0 |       2 |
/// | Rab 2026-09-16 | active `[1,3,5]`       | done                          |       1 |       2 |
/// | Sen 2026-09-21 | paused                 | none                          |       1 |       2 |
/// | Sel 2026-09-29 | active `[2,4]`         | done                          |       2 |       2 |
///
/// Dart, Node.js, and the recompute migration must all reproduce this table.
void main() {
  test('Habit streak evaluator matches the schema 11.3 golden table', () {},
      skip: 'M4: Habit/HabitSchedule/HabitLog do not exist yet');
}
