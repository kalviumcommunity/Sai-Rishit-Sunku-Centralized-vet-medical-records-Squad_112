import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare/main.dart';

void main() {
  testWidgets('VetCare app smoke test, splash and Day 3 login screen render', (WidgetTester tester) async {
    // 1. Build app and verify initial Day 2 splash render
    await tester.pumpWidget(const VetCareApp());
    expect(find.text('VetCare'), findsOneWidget);
    expect(find.text('Centralized Veterinary Medical Records'), findsOneWidget);
    expect(find.text('Multi-Branch Network Ready'), findsOneWidget);
    expect(find.text('Single ID'), findsOneWidget);
    expect(find.text('Cross-Clinic'), findsOneWidget);

    // 2. Advance time past splash timer and settle navigation to Day 3 Login
    await tester.pumpAndSettle();

    // Verify Day 3 Login Screen Header & Subtitle
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text("Log in to view your pet's health records"), findsOneWidget);

    // Verify Fields and Actions
    expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('or continue with'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    // Verify Touchless Lobby Check-in static card (UI placeholder)
    expect(find.text('Arrived at the Clinic?'), findsOneWidget);
    expect(find.text('Tap for fast touchless lobby check-in'), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);
  });
}
