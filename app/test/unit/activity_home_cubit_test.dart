import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:dailys/features/activity/activity_home_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
    tzdata.initializeTimeZones();
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';
  late tz.Location jakarta;
  setUpAll(() => jakarta = tz.getLocation('Asia/Jakarta'));

  late AppDatabase db;
  late String kuliahCategoryId;
  const today = LocalDate(2026, 9, 14); // Monday

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    kuliahCategoryId = DeterministicId.seedActivityCategory(userId, 'kuliah');
  });
  tearDown(() => db.close());

  ActivityHomeCubit makeCubit() =>
      ActivityHomeCubit(db: db, userId: userId, location: jakarta, initialDate: today);

  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('starts on the given date with empty state, then loads categories', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    expect(cubit.state.date, today);
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.categories, isNotEmpty); // 6 seeds from provisioning
  });

  test('createManualActivity appears in state.timed, split from untimed', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();

    await cubit.createManualActivity(
      judul: 'Kelas Basis Data',
      activityCategoryId: kuliahCategoryId,
      startTime: DateTime.utc(2026, 9, 14, 2), // 09:00 WIB
      endTime: DateTime.utc(2026, 9, 14, 3),
    );
    await cubit.createManualActivity(
      judul: 'Catatan bebas',
      activityCategoryId: kuliahCategoryId,
      isAllDay: true,
    );
    await pump();

    expect(cubit.state.timed, hasLength(1));
    expect(cubit.state.timed.single.judul, 'Kelas Basis Data');
    expect(cubit.state.untimed, hasLength(1));
    expect(cubit.state.untimed.single.judul, 'Catatan bebas');
  });

  test('all-day activity forces empty reminder offsets (schema 8 invariant)', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    await cubit.createManualActivity(
      judul: 'Libur',
      activityCategoryId: kuliahCategoryId,
      isAllDay: true,
      reminderOffsetsMinutes: const [30], // must be dropped
    );
    await pump();
    expect(cubit.state.untimed.single.reminderOffsetsMinutes, isEmpty);
  });

  test('completion rate reflects only selesai among active occurrences', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    await cubit.createManualActivity(judul: 'A', activityCategoryId: kuliahCategoryId);
    await cubit.createManualActivity(judul: 'B', activityCategoryId: kuliahCategoryId);
    await pump();

    final aId = cubit.state.activities.firstWhere((a) => a.judul == 'A').id;
    await cubit.setStatus(aId, ActivityStatus.selesai);
    await pump();

    expect(cubit.state.completionRatePercent, 50.0);
  });

  test('overlap warnings surface for intersecting timed activities', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    await cubit.createManualActivity(
      judul: 'A',
      activityCategoryId: kuliahCategoryId,
      startTime: DateTime.utc(2026, 9, 14, 2), // 09:00 WIB
      endTime: DateTime.utc(2026, 9, 14, 3, 30), // 10:30 WIB
    );
    await cubit.createManualActivity(
      judul: 'B',
      activityCategoryId: kuliahCategoryId,
      startTime: DateTime.utc(2026, 9, 14, 3), // 10:00 WIB
      endTime: DateTime.utc(2026, 9, 14, 4), // 11:00 WIB
    );
    await pump();

    expect(cubit.state.overlaps, hasLength(1));
  });

  test('deleteActivity soft-deletes and removes it from the date view', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    await cubit.createManualActivity(judul: 'A', activityCategoryId: kuliahCategoryId);
    await pump();
    final id = cubit.state.activities.single.id;

    await cubit.deleteActivity(id);
    await pump();

    expect(cubit.state.activities, isEmpty);
  });

  test('goToNextDay/goToPreviousDay switch the watched date', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    await cubit.createManualActivity(judul: 'Today', activityCategoryId: kuliahCategoryId);
    await pump();

    cubit.goToNextDay();
    await pump();
    expect(cubit.state.date, today.addDays(1));
    expect(cubit.state.activities, isEmpty);

    cubit.goToPreviousDay();
    await pump();
    expect(cubit.state.date, today);
    expect(cubit.state.activities, hasLength(1));
  });

  test('createRecurringSeries materializes occurrences immediately', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();

    await cubit.createRecurringSeries(
      judul: 'Kelas rutin',
      activityCategoryId: kuliahCategoryId,
      recurringDays: const [1, 3, 5], // Mon/Wed/Fri; today is Monday
      startsOn: today,
      startTime: '09:00:00',
      endTime: '10:00:00',
    );
    await pump();

    expect(cubit.state.activities, hasLength(1));
    expect(cubit.state.activities.single.source, ActivitySource.manual);
    expect(cubit.state.activities.single.recurrenceId, isNotNull);
  });
}
