import 'package:flutter_test/flutter_test.dart';
import 'package:project_1/main.dart';

void main() {
  testWidgets('Counter removal test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LoomeeApp());

    // Verify that our title exists.
    expect(find.text('Loomeé'), findsOneWidget);
  });
}