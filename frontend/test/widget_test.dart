import 'package:flutter_test/flutter_test.dart';
import 'package:loomee/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const LoomeeApp());
    expect(find.text('Loomee'), findsOneWidget);
  });
}
