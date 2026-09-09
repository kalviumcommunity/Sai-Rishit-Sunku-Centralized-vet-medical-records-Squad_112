import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare/main.dart';

void main() {
  testWidgets('VetCare app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VetCareApp());

    // Verify that the brand title is displayed.
    expect(find.text('VetCare'), findsOneWidget);
  });
}
