import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dailys/main.dart';

void main() {
  testWidgets('App boots and shows Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DailysApp()));
    await tester.pumpAndSettle();

    expect(find.text('Home — Activity & Timebox'), findsOneWidget);
  });
}
