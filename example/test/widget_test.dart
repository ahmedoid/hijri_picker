import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('App renders the demo home page', (WidgetTester tester) async {
    await tester.pumpWidget(const HijriPickerDemoApp());
    await tester.pumpAndSettle();
    expect(find.text('Hijri Picker Demo'), findsOneWidget);
    expect(find.text('Open (basic)'), findsOneWidget);
  });
}
