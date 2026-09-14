import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/features/activity/activity_home_screen.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'design_alignment_test.dart' as qa;

void checkDescendants(WidgetTester tester, Finder root) {
  final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
  void visit(Element element, bool horizontalScroll) {
    final widget = element.widget;
    if (widget is Offstage && widget.offstage) return;
    final scroll = horizontalScroll ||
        (widget is Scrollable &&
            axisDirectionToAxis(widget.axisDirection) == Axis.horizontal);
    if (!scroll &&
        element is RenderObjectElement &&
        element.renderObject is RenderBox) {
      final box = element.renderObject as RenderBox;
      if (box.hasSize && box.size.width > 0 && box.attached) {
        final left = box.localToGlobal(Offset.zero).dx;
        expect(left, greaterThanOrEqualTo(-1),
            reason: '${widget.runtimeType} left');
        expect(left + box.size.width, lessThanOrEqualTo(width + 1),
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
  setUpAll(qa.initializeQa);
  testWidgets(
      'Home follow-up refill, flexible list, detail, edit, modes and descendant bounds',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1408, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
        userId: qa.userId,
        deviceId: qa.deviceId,
        nama: 'QA',
        apiKeyHash: 'test-only');
    final categories = (await tester.runAsync(
        () => db.activityDao.watchPickableCategories(qa.userId).first))!;
    final now = DateTime.now().toUtc();
    final local = now.add(const Duration(hours: 7));
    final date =
        '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final ids = <String>[];
    for (var i = 0; i < 5; i++) {
      final id = DeterministicId.v4();
      ids.add(id);
      await db.activityDao.insertActivity(ActivityCompanion.insert(
          id: id,
          createdAt: now.add(Duration(seconds: i)),
          updatedAt: now,
          userId: qa.userId,
          occurrenceDate: date,
          judul: i == 4
              ? 'Sudah selesai tanpa jam'
              : 'Aktivitas fleksibel ${i + 1} dengan judul panjang untuk memeriksa reflow',
          activityCategoryId: categories.first.id,
          status: i == 4 ? ActivityStatus.selesai : ActivityStatus.belum_mulai,
          source: ActivitySource.manual));
    }
    await db.activityDao.insertActivity(ActivityCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: now,
        updatedAt: now,
        userId: qa.userId,
        occurrenceDate: date,
        judul: 'Hasil Habit tidak menjadi kandidat',
        activityCategoryId: categories.first.id,
        status: ActivityStatus.selesai,
        source: ActivitySource.habit,
        sourceId: Value(DeterministicId.v4())));
    await db.activityDao.insertActivity(ActivityCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: now,
        updatedAt: now,
        userId: qa.userId,
        occurrenceDate: date,
        judul:
            'Aktivitas berjam dengan judul panjang untuk membandingkan kartu jadwal dan detail',
        activityCategoryId: categories.first.id,
        startTime: Value(DateTime.utc(local.year, local.month, local.day, 2)),
        endTime: Value(DateTime.utc(local.year, local.month, local.day, 3)),
        status: ActivityStatus.belum_mulai,
        source: ActivitySource.manual));
    await tester.pumpWidget(qa.wrap(
        ActivityHomeScreen(db: db, userId: qa.userId, deviceId: qa.deviceId),
        false));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('follow-up-${ids[0]}')), findsOneWidget);
    expect(find.byKey(ValueKey('follow-up-${ids[2]}')), findsOneWidget);
    expect(find.byKey(ValueKey('follow-up-${ids[3]}')), findsNothing);
    final first = find.byKey(ValueKey('follow-up-${ids[0]}'));
    await tester.ensureVisible(first);
    await tester
        .tap(find.descendant(of: first, matching: find.text('Tentukan waktu')));
    await tester.pumpAndSettle();
    expect(find.text('Edit aktivitas'), findsOneWidget);
    expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .focusNode
            .hasFocus,
        isTrue);
    checkDescendants(tester, find.byType(Dialog));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('follow-up-${ids[0]}')), findsOneWidget);
    await tester.ensureVisible(first);
    await tester
        .tap(find.descendant(of: first, matching: find.text('Tandai selesai')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('follow-up-${ids[0]}')), findsNothing);
    expect(find.byKey(ValueKey('follow-up-${ids[3]}')), findsOneWidget);
    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Sudah selesai tanpa jam'), findsOneWidget);
    for (final width in [320.0, 440.0, 736.0, 860.0, 1408.0]) {
      for (final dark in [false, true]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpWidget(qa.wrap(
            ActivityHomeScreen(
                db: db, userId: qa.userId, deviceId: qa.deviceId),
            dark));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Tambah aktivitas'));
        await tester.tap(find.text('Tambah aktivitas'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'dialog/$width/$dark');
        checkDescendants(tester, find.byType(Dialog));
        expect(
            tester
                .widget<EditableText>(find.byType(EditableText).first)
                .focusNode
                .hasFocus,
            isTrue);
        await tester.tap(find.byIcon(Icons.close).last);
        await tester.pumpAndSettle();
        for (final mode in ['Daftar', 'Timeline', 'Minggu']) {
          await tester.ensureVisible(find.text(mode));
          await tester.tap(find.text(mode));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$width/$dark/$mode');
          checkDescendants(tester, find.byType(ActivityHomeScreen));
          await tester.runAsync(() => qa.capture(tester,
              'home-current-${width.toInt()}-${dark ? 'dark' : 'light'}-$mode'));
          if (mode == 'Minggu') {
            expect(find.text('Perlu ditindaklanjuti'), findsNothing);
          }
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    }
  });
}
