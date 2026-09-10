import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare/main.dart';

void main() {
  testWidgets('VetCare app smoke test and splash navigation', (WidgetTester tester) async {
    // 1. Build app and verify initial splash render
    await tester.pumpWidget(const VetCareApp());
    expect(find.text('VetCare'), findsOneWidget);
    expect(find.text('Centralized Veterinary Medical Records'), findsOneWidget);
    expect(find.text('Multi-Branch Network Ready'), findsOneWidget);
    expect(find.text('Single ID'), findsOneWidget);
    expect(find.text('Cross-Clinic'), findsOneWidget);

    // 2. Advance time past splash timer and settle navigation to Login
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
