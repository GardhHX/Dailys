import 'dart:ffi' show DynamicLibrary;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dailys/app/theme/app_theme.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/features/activity/activity_home_screen.dart';
import 'package:dailys/features/onboarding/onboarding_screen.dart';
import 'package:dailys/features/settings/settings_screen.dart';
import 'package:dailys/features/tugas/tugas_list_screen.dart';
import 'package:dailys/features/splash/splash_screen.dart';
import 'package:dailys/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:dailys/features/tugas/tugas_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

const userId = '11111111-1111-4111-8111-111111111111';
const deviceId = '22222222-2222-4222-8222-222222222222';
const captureKey = ValueKey('ui-capture');

Widget wrap(Widget child, bool dark,
        {String language = 'id', double scale = 1}) =>
    MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: RepaintBoundary(key: captureKey, child: child!)),
      home: child,
    );

Future<void> capture(WidgetTester tester, String name) async {
  if (Platform.environment['DAILYS_UI_CAPTURE'] != '1') return;
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(captureKey));
  final image = await boundary.toImage();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('build/ui-qa/$name.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
}

Future<void> initializeQa() async {
  if (Platform.isWindows) {
    open.overrideFor(
        OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final font = FontLoader('Segoe UI');
    font.addFont(Future.value(ByteData.sublistView(
        await File(r'C:\Windows\Fonts\segoeui.ttf').readAsBytes())));
    await font.load();
  }
}

void checkDescendants(WidgetTester tester, Finder root) {
  final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
  void visit(Element element, bool horizontalScroll) {
    final widget = element.widget;
    if (widget is Offstage && widget.offstage) return;
    // Slider's indicator reserves a viewport-sized overlay at the thumb's
    // offset. Its box is not the bounds of the label painted inside it.
    if (widget.runtimeType.toString() == '_ValueIndicatorRenderObjectWidget') {
      return;
    }
    final scroll = horizontalScroll ||
        (widget is Scrollable &&
            axisDirectionToAxis(widget.axisDirection) == Axis.horizontal);
    if (!scroll &&
        element is RenderObjectElement &&
        element.renderObject is RenderBox) {
      final box = element.renderObject as RenderBox;
      if (box.hasSize && box.size.width > 0 && box.attached) {
        final bounds = MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
        expect(bounds.left, greaterThanOrEqualTo(-1),
            reason: '${widget.runtimeType} left');
        expect(bounds.right, lessThanOrEqualTo(width + 1),
            reason: '${widget.runtimeType} right');
      }
    }
    element.visitChildren((child) => visit(child, scroll));
  }

  for (final element in root.evaluate()) {
    visit(element, false);
  }
}

void main() {
  setUpAll(initializeQa);

  for (final width in [320.0, 440.0, 736.0, 860.0, 1408.0]) {
    for (final dark in [false, true]) {
      testWidgets(
          'existing screens fit width $width, dark=$dark, ID/EN and text 200%',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1000);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        await db.provisionLocalUser(
            userId: userId,
            deviceId: deviceId,
            nama: 'QA',
            apiKeyHash: 'test-only');
        final screens = <String, Widget>{
          'home':
              ActivityHomeScreen(db: db, userId: userId, deviceId: deviceId),
          'tasks': TugasListScreen(db: db, userId: userId, deviceId: deviceId),
          'onboarding': OnboardingScreen(
              db: db, userId: userId, deviceId: deviceId, onCompleted: () {}),
          'settings':
              SettingsScreen(db: db, userId: userId, deviceId: deviceId),
        };
        for (final entry in screens.entries) {
          await tester.pumpWidget(wrap(entry.value, dark));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '${entry.key} at $width');
          checkDescendants(tester, find.byType(MaterialApp));
          await tester.runAsync(() => capture(tester,
              '${entry.key}-${width.toInt()}-${dark ? 'dark' : 'light'}'));
          if (entry.key == 'home') {
            await tester.tap(find.text('Tambah aktivitas').first);
            await tester.pumpAndSettle();
            expect(find.byType(Dialog), findsOneWidget);
            expect(
                tester
                    .widget<EditableText>(find.byType(EditableText).first)
                    .focusNode
                    .hasFocus,
                isTrue);
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
            await tester.pumpAndSettle();
            expect(find.byType(Dialog), findsNothing);
          }
          await tester
              .pumpWidget(wrap(entry.value, dark, language: 'en', scale: 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '${entry.key} EN text 200% at $width');
          checkDescendants(tester, find.byType(MaterialApp));
          if (entry.key == 'tasks') {
            await tester.tap(find.text('Add task'));
            await tester.pumpAndSettle();
            expect(find.byType(Dialog), findsOneWidget);
            expect(tester.takeException(), isNull);
            await tester.runAsync(() => capture(tester,
                'tasks-modal-${width.toInt()}-${dark ? 'dark' : 'light'}-en200'));
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
            await tester.pumpAndSettle();
            expect(find.byType(Dialog), findsNothing);
            await tester.tap(find.text('History'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.tap(find.text('Courses & notes'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      });
    }
  }

  testWidgets('Home long titles and populated deadlines fit desktop and phone',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1408, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
        userId: userId,
        deviceId: deviceId,
        nama: 'QA',
        apiKeyHash: 'test-only');
    final settings = await db.settingsDao.getUserSettings(userId);
    final categories = (await tester
        .runAsync(() => db.activityDao.watchPickableCategories(userId).first))!;
    final now = DateTime.now().toUtc();
    await db.activityDao.insertActivity(ActivityCompanion.insert(
        id: '33333333-3333-4333-8333-333333333333',
        createdAt: now,
        updatedAt: now,
        userId: userId,
        occurrenceDate: DateTime.now().toIso8601String().substring(0, 10),
        judul:
            'Aktivitas dengan judul panjang untuk memeriksa susunan teks dan kontrol pada layar ponsel',
        activityCategoryId: categories.first.id,
        status: ActivityStatus.belum_mulai,
        source: ActivitySource.manual));
    await db.tugasDao.insertTugas(TugasCompanion.insert(
        id: '44444444-4444-4444-8444-444444444444',
        createdAt: now,
        updatedAt: now,
        userId: userId,
        judul:
            'Deadline dengan judul panjang untuk memeriksa pembungkusan teks',
        deadline: now.subtract(const Duration(days: 1)),
        prioritas: TugasPrioritas.high,
        status: TugasStatus.progress,
        reminders: const []));
    expect(settings, isNotNull);
    for (final width in [1408.0, 320.0]) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pumpWidget(wrap(
          ActivityHomeScreen(db: db, userId: userId, deviceId: deviceId),
          false));
      await tester.pumpAndSettle();
      expect(find.textContaining('Deadline dengan judul'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester
          .runAsync(() => capture(tester, 'home-populated-${width.toInt()}'));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Splash failure remains readable and offers retry',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrap(
        SplashScreen(
            databaseOpener: () async => throw StateError('QA failure'),
            onReady: (_, __, ___, ____) {}),
        true,
        scale: 2));
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets(
      'Home, Tasks and Settings read failures show retry instead of an endless loader',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
        userId: userId,
        deviceId: deviceId,
        nama: 'QA',
        apiKeyHash: 'test-only');
    await db.customStatement('DROP TABLE user_settings');
    for (final screen in [
      ActivityHomeScreen(db: db, userId: userId, deviceId: deviceId),
      SettingsScreen(db: db, userId: userId, deviceId: deviceId),
      TugasListScreen(db: db, userId: userId, deviceId: deviceId)
    ]) {
      await tester.pumpWidget(wrap(screen, false));
      await tester.pumpAndSettle();
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
  testWidgets(
      'Tasks navigation, cards, detail checklist, filters, history, courses and add modal',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1408, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
        userId: userId,
        deviceId: deviceId,
        nama: 'QA',
        apiKeyHash: 'test-only');
    final now = DateTime.now().toUtc();
    const taskId = '55555555-5555-4555-8555-555555555555';
    const courseId = '66666666-6666-4666-8666-666666666666';
    const title = 'Rancangan basis data';
    await db.mataKuliahDao.insertMataKuliah(MataKuliahCompanion.insert(
        id: courseId,
        createdAt: now,
        updatedAt: now,
        userId: userId,
        nama: 'Sistem Basis Data',
        warna: '#3538a0'));
    await db.tugasDao.insertTugas(TugasCompanion.insert(
        id: taskId,
        createdAt: now,
        updatedAt: now,
        userId: userId,
        judul: title,
        deskripsi: const Value(
            'Susun ERD dan normalisasi skema untuk studi kasus perpustakaan.'),
        mataKuliahId: const Value(courseId),
        deadline: now.subtract(const Duration(days: 1)),
        prioritas: TugasPrioritas.high,
        status: TugasStatus.progress,
        reminders: const []));
    await db.tugasDao.insertTugas(TugasCompanion.insert(
        id: '77777777-7777-4777-8777-777777777777',
        createdAt: now,
        updatedAt: now,
        userId: userId,
        judul:
            'Tugas dengan judul panjang untuk memeriksa reflow kartu dan metadata pada layar ponsel',
        deadline: now.add(const Duration(days: 2)),
        prioritas: TugasPrioritas.medium,
        status: TugasStatus.belum,
        reminders: const []));
    await db.tugasDao.insertChecklistItem(TugasChecklistCompanion.insert(
        id: '88888888-8888-4888-8888-888888888888',
        createdAt: now,
        updatedAt: now,
        tugasId: taskId,
        judul: 'Selesaikan ERD',
        urutan: 0));
    await tester.pumpWidget(wrap(
        ActivityHomeScreen(db: db, userId: userId, deviceId: deviceId), false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tugas').first);
    await tester.pumpAndSettle();
    expect(find.byType(TugasListScreen), findsOneWidget);
    expect(find.text('2 tugas aktif'), findsOneWidget);
    expect(find.text('0/1 checklist selesai'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.runAsync(() => capture(tester, 'tasks-populated-1408-light'));
    await tester.ensureVisible(find.text(title).first);
    await tester.tap(find.text(title).first);
    await tester.pumpAndSettle();
    expect(find.byType(TugasDetailScreen), findsOneWidget);
    await tester.runAsync(() => capture(tester, 'tasks-detail-1408-light'));
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    expect(
        find.text('Semua item selesai. Tandai tugas selesai?'), findsOneWidget);
    final stored =
        (await tester.runAsync(() => db.tugasDao.watchTugasById(taskId).first));
    expect(stored!.status, TugasStatus.progress);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah tugas'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.enterText(
        find.byType(TextField).first, 'Tugas baru dari modal');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('3 tugas aktif'), findsOneWidget);
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada riwayat pada minggu ini'), findsOneWidget);
    await tester.tap(find.text('Mata kuliah & catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Sistem Basis Data'), findsOneWidget);
    await tester.tap(find.text('Sistem Basis Data'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada catatan'), findsOneWidget);
    await tester.tap(find.text('Tambah catatan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Materi normalisasi');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Materi normalisasi'), findsOneWidget);
    await tester.runAsync(() => capture(tester, 'tasks-course-1408-light'));
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tugas aktif'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progress').last);
    await tester.pumpAndSettle();
    expect(find.text('1 tugas aktif'), findsOneWidget);
    await tester.tap(find.text('Hapus filter'));
    await tester.pumpAndSettle();
    expect(find.text('3 tugas aktif'), findsOneWidget);
    tester.view.physicalSize = const Size(320, 1000);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.runAsync(() => capture(tester, 'tasks-populated-320-light'));
    await tester.ensureVisible(find.text(title).first);
    await tester.tap(find.text(title).first);
    await tester.pumpAndSettle();
    expect(find.byType(TugasDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.runAsync(() => capture(tester, 'tasks-detail-320-light'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    for (final width in [320.0, 1408.0]) {
      for (final dark in [false, true]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpWidget(wrap(
            TugasListScreen(db: db, userId: userId, deviceId: deviceId), dark,
            language: 'en', scale: 2));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() => capture(tester,
            'tasks-populated-${width.toInt()}-${dark ? 'dark' : 'light'}-en200'));
        await tester.ensureVisible(find.text(title).first);
        await tester.tap(find.text(title).first);
        await tester.pumpAndSettle();
        expect(find.byType(TugasDetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.runAsync(() => capture(tester,
            'tasks-detail-${width.toInt()}-${dark ? 'dark' : 'light'}-en200'));
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Courses & notes'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sistem Basis Data'));
        await tester.pumpAndSettle();
        expect(find.text('Materi normalisasi'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Add note'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() => capture(tester,
            'tasks-note-modal-${width.toInt()}-${dark ? 'dark' : 'light'}-en200'));
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
