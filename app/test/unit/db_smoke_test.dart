import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dailys/core/db/backup/backup_cipher.dart';
import 'package:dailys/core/db/backup/backup_key_store.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/migrations.dart';
import 'package:dailys/core/db/seed/category_seed.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// Smoke tests for the M1 Drift layer: provisioning + seeds, delete/detach
/// policy, active-unique constraints, restart persistence, and the OPERATIONS 3
/// backup-before-migration flow.
///
/// `flutter test` runs on the Dart VM, where the `sqlite3_flutter_libs` bundled
/// binary is not loaded, so on Windows we point sqlite3 at the system
/// `winsqlite3.dll` (SQLite >= 3.27, which supports `VACUUM INTO`).
void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(
        OperatingSystem.windows,
        () => DynamicLibrary.open('winsqlite3.dll'),
      );
    }
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';

  AppDatabase memoryDb() => AppDatabase(NativeDatabase.memory());

  group('provisioning + seeds', () {
    late AppDatabase db;
    setUp(() => db = memoryDb());
    tearDown(() => db.close());

    test('creates user, deterministic settings, device row, and 6 seeds', () async {
      await db.provisionLocalUser(
        userId: userId,
        deviceId: deviceId,
        nama: 'Mahasiswa',
        apiKeyHash: 'hash',
      );

      expect((await db.select(db.users).get()).length, 1);

      final settings = await db.select(db.userSettings).getSingle();
      expect(settings.id, DeterministicId.userSettings(userId));
      expect(settings.userId, userId);
      expect(settings.language, Language.id);
      expect(settings.timezone, 'Asia/Jakarta');
      expect(settings.pomodoroFocusMinutes, 25);

      final device = await db.select(db.deviceSettings).getSingle();
      expect(device.deviceId, deviceId);
      expect(device.theme, ThemePreference.system);

      final cats = await db.select(db.activityCategory).get();
      expect(cats.length, kSeedActivityCategories.length);
      expect(cats.every((c) => c.isSystem), isTrue);
      final kuliah = cats.firstWhere((c) => c.nama == 'Kuliah');
      expect(kuliah.id, DeterministicId.seedActivityCategory(userId, 'kuliah'));
    });

    test('re-provisioning is idempotent', () async {
      await db.provisionLocalUser(
          userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
      await db.provisionLocalUser(
          userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');

      expect((await db.select(db.users).get()).length, 1);
      expect((await db.select(db.activityCategory).get()).length,
          kSeedActivityCategories.length);
    });
  });

  group('delete policies (schema Section 2)', () {
    late AppDatabase db;
    final now = DateTime.utc(2026, 9, 13, 3);
    setUp(() async {
      db = memoryDb();
      await db.provisionLocalUser(
          userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    });
    tearDown(() => db.close());

    test('MataKuliah delete tombstones notes and detaches tasks', () async {
      const mkId = '11111111-1111-4111-8111-111111111111';
      await db.mataKuliahDao.insertMataKuliah(MataKuliahCompanion.insert(
        id: mkId,
        createdAt: now,
        updatedAt: now,
        userId: userId,
        nama: 'Basis Data',
        warna: '#4C6FFF',
      ));
      await db.mataKuliahDao.insertCourseNote(CourseNoteCompanion.insert(
        id: '22222222-2222-4222-8222-222222222222',
        createdAt: now,
        updatedAt: now,
        mataKuliahId: mkId,
        tanggal: '2026-09-10',
        isi: 'Normalisasi',
      ));
      const tugasId = '33333333-3333-4333-8333-333333333333';
      await db.tugasDao.insertTugas(TugasCompanion.insert(
        id: tugasId,
        createdAt: now,
        updatedAt: now,
        userId: userId,
        judul: 'ERD',
        deadline: now,
        prioritas: TugasPrioritas.high,
        status: TugasStatus.belum,
        reminders: const [],
        mataKuliahId: const Value(mkId),
      ));

      await db.mataKuliahDao.softDeleteMataKuliah(mkId, now: now);

      final mk = await (db.select(db.mataKuliah)
            ..where((t) => t.id.equals(mkId)))
          .getSingle();
      expect(mk.isDeleted, isTrue);
      final note = await (db.select(db.courseNote)).getSingle();
      expect(note.isDeleted, isTrue);
      final tg = await (db.select(db.tugas)..where((t) => t.id.equals(tugasId)))
          .getSingle();
      expect(tg.isDeleted, isFalse, reason: 'task detached, not deleted');
      expect(tg.mataKuliahId, null);
    });

    test('Tugas delete cascades checklist', () async {
      const tugasId = '44444444-4444-4444-8444-444444444444';
      await db.tugasDao.insertTugas(TugasCompanion.insert(
        id: tugasId,
        createdAt: now,
        updatedAt: now,
        userId: userId,
        judul: 'Laporan',
        deadline: now,
        prioritas: TugasPrioritas.medium,
        status: TugasStatus.belum,
        reminders: const [],
      ));
      await db.tugasDao.insertChecklistItem(TugasChecklistCompanion.insert(
        id: '55555555-5555-4555-8555-555555555555',
        createdAt: now,
        updatedAt: now,
        tugasId: tugasId,
        judul: 'Bab 1',
        urutan: 0,
      ));

      await db.tugasDao.softDeleteTugas(tugasId, now: now);

      expect((await db.select(db.tugasChecklist).getSingle()).isDeleted, isTrue);
      expect(
          (await (db.select(db.tugas)..where((t) => t.id.equals(tugasId)))
                  .getSingle())
              .isDeleted,
          isTrue);
    });
  });

  test('active-unique index blocks duplicate recurring occurrence', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final now = DateTime.utc(2026, 9, 13, 3);
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    final catId = DeterministicId.seedActivityCategory(userId, 'kuliah');

    const recId = '66666666-6666-4666-8666-666666666666';
    await db.activityDao.insertRecurrence(ActivityRecurrenceCompanion.insert(
      id: recId,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      judul: 'Kelas',
      activityCategoryId: catId,
      recurringDays: const [1, 3, 5],
      startsOn: '2026-09-01',
    ));

    ActivityCompanion occ(String id) => ActivityCompanion.insert(
          id: id,
          createdAt: now,
          updatedAt: now,
          userId: userId,
          occurrenceDate: '2026-09-14',
          judul: 'Kelas',
          activityCategoryId: catId,
          status: ActivityStatus.belum_mulai,
          source: ActivitySource.manual,
          recurrenceId: const Value(recId),
        );

    await db.activityDao.insertActivity(occ('77777777-7777-4777-8777-777777777777'));
    await expectLater(
      db.activityDao.insertActivity(occ('88888888-8888-4888-8888-888888888888')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('data survives a restart (reopen file)', () async {
    final dir = await Directory.systemTemp.createTemp('dailys_restart');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/dailys.db');

    var db = AppDatabase(NativeDatabase(file));
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect((await db.select(db.users).get()).length, 1);
    expect((await db.select(db.activityCategory).get()).length,
        kSeedActivityCategories.length);
  });

  test('M1 user data (Activity, Tugas, checklist) survives a restart', () async {
    final dir = await Directory.systemTemp.createTemp('dailys_restart_data');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/dailys.db');
    final now = DateTime.utc(2026, 9, 14, 3);

    var db = AppDatabase(NativeDatabase(file));
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    final catId = DeterministicId.seedActivityCategory(userId, 'kuliah');

    const activityId = '99999999-9999-4999-8999-999999999999';
    await db.activityDao.insertActivity(ActivityCompanion.insert(
      id: activityId,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      occurrenceDate: '2026-09-14',
      judul: 'Kelas Basis Data',
      activityCategoryId: catId,
      status: ActivityStatus.belum_mulai,
      source: ActivitySource.manual,
    ));

    const tugasId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    await db.tugasDao.insertTugas(TugasCompanion.insert(
      id: tugasId,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      judul: 'Laporan Akhir',
      deadline: now,
      prioritas: TugasPrioritas.high,
      status: TugasStatus.belum,
      reminders: const [],
    ));
    await db.tugasDao.insertChecklistItem(TugasChecklistCompanion.insert(
      id: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
      createdAt: now,
      updatedAt: now,
      tugasId: tugasId,
      judul: 'Bab 1',
      urutan: 0,
    ));
    await db.close(); // close cleanly before reopening the same file

    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final activity =
        await (db.select(db.activity)..where((a) => a.id.equals(activityId))).getSingle();
    expect(activity.judul, 'Kelas Basis Data');
    expect(activity.status, ActivityStatus.belum_mulai);

    final tugas =
        await (db.select(db.tugas)..where((t) => t.id.equals(tugasId))).getSingle();
    expect(tugas.judul, 'Laporan Akhir');
    expect(tugas.prioritas, TugasPrioritas.high);

    final checklist = await (db.select(db.tugasChecklist)
          ..where((c) => c.tugasId.equals(tugasId)))
        .getSingle();
    expect(checklist.judul, 'Bab 1');
    expect(checklist.isDone, isFalse);
  });

  test('OPERATIONS 3 backup: encrypted, verified, decryptable round-trip', () async {
    final dir = await Directory.systemTemp.createTemp('dailys_backup');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/dailys.db');

    final db = AppDatabase(NativeDatabase(file));
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    await db.close(); // release the file before copying

    final key = await InMemoryBackupKeyStore().getOrCreateKey();
    final result = await MigrationSafety.backupBeforeMigration(
      sourceDbPath: file.path,
      backupDir: '${dir.path}/backups',
      deviceId: deviceId,
      appVersion: '0.1.0+1',
      fromSchemaVersion: 1,
      toSchemaVersion: 2,
      encryptionKey: key,
      now: DateTime.utc(2026, 9, 13, 3),
    );

    // Artifact is the encrypted container; no plaintext temp left behind.
    expect(result.backupPath, endsWith('.db.enc'));
    expect(File(result.backupPath).existsSync(), isTrue);
    expect(Directory('${dir.path}/backups')
        .listSync()
        .whereType<File>()
        .any((f) => f.path.endsWith('.plain.tmp')), isFalse);

    final manifest = File(result.manifestPath).readAsStringSync();
    expect(manifest, contains('"encrypted": true'));
    expect(manifest, contains('"cipher": "AES-256-GCM"'));
    expect(manifest, contains('"sha256": "${result.ciphertextSha256}"'));
    expect(manifest, contains('"user": 1'));
    expect(manifest,
        contains('"activity_category": ${kSeedActivityCategories.length}'));

    // The stored file is not a plaintext SQLite DB (starts with DBK1 magic).
    final head = File(result.backupPath).readAsBytesSync().sublist(0, 4);
    expect(head, BackupCipher.magic);

    // Wrong key fails the GCM tag.
    final badKey = List<int>.generate(32, (_) => 0);
    await expectLater(
      BackupCipher().decryptToBytes(input: File(result.backupPath), key: badKey),
      throwsA(anything),
    );

    // Correct key decrypts back to a valid SQLite DB matching plaintext hash.
    final clear = await BackupCipher()
        .decryptToBytes(input: File(result.backupPath), key: key);
    expect(sha256.convert(clear).toString(), result.plaintextSha256);

    final restored = File('${dir.path}/restored.db')..writeAsBytesSync(clear);
    final rdb = sqlite3.open(restored.path);
    addTearDown(rdb.dispose);
    expect(rdb.select('PRAGMA integrity_check').first.values.first, 'ok');
    expect(rdb.select('SELECT COUNT(*) AS n FROM "user"').first['n'], 1);
  });
}
