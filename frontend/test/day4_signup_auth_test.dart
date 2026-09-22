import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare/models/user_model.dart';
import 'package:vetcare/routes/app_routes.dart';
import 'package:vetcare/screens/auth/signup_screen.dart';
import 'package:vetcare/screens/owner/owner_home_screen.dart';
import 'package:vetcare/screens/owner/profile_screen.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/utils/constants.dart';

void main() {
  group('DAY 4 — Signup Screen UI & Role Selection Tests', () {
    testWidgets('renders all required Day 4 SignupScreen UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const SignupScreen(),
          ),
        ),
      );

      // Verify "Step 1 of 2" label
      expect(find.text('Step 1 of 2'), findsOneWidget);

      // Verify Header
      expect(find.text('Create your account'), findsOneWidget);

      // Verify Role Chips
      expect(find.text('Pet Owner'), findsOneWidget);
      expect(find.text('Veterinarian'), findsOneWidget);

      // Verify Form Fields
      expect(find.widgetWithText(TextField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email Address'), findsOneWidget);
      expect(find.text('Password (min 6 chars)'), findsOneWidget);

      // Verify Static Info Card: "Multi-Clinic Unified Sync"
      expect(find.text('Multi-Clinic Unified Sync'), findsOneWidget);

      // Verify "SIGN UP" button
      expect(find.widgetWithText(ElevatedButton, 'SIGN UP'), findsOneWidget);

      // Verify Sign In redirect link
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('switching role chip toggles clinic branch ID field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const SignupScreen(),
          ),
        ),
      );

      // Initially Pet Owner: no Branch ID field
      expect(find.text('Clinic Branch ID (Optional)'), findsNothing);

      // Select Veterinarian Chip
      await tester.tap(find.text('Veterinarian'));
      await tester.pump();

      // Branch ID field now visible
      expect(find.text('Clinic Branch ID (Optional)'), findsOneWidget);

      // Switch back to Pet Owner
      await tester.tap(find.text('Pet Owner'));
      await tester.pump();

      // Branch ID field hidden again
      expect(find.text('Clinic Branch ID (Optional)'), findsNothing);
    });

    testWidgets('Veterinarian can submit without Clinic Branch ID since it is optional', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const SignupScreen(),
          ),
        ),
      );

      // Select Veterinarian Chip
      await tester.tap(find.text('Veterinarian'));
      await tester.pump();

      // Enter Name, Email, Password, but leave Clinic Branch ID empty
      await tester.enterText(find.widgetWithText(TextField, 'Full Name'), 'Dr. John Doe');
      await tester.enterText(find.widgetWithText(TextField, 'Email Address'), 'drjohn@vetcare.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password (min 6 chars)'), 'password123');

      final signupBtn = find.widgetWithText(ElevatedButton, 'SIGN UP');
      await tester.ensureVisible(signupBtn);
      await tester.tap(signupBtn);
      await tester.pump();

      // Verify no "Please specify your primary clinic branch ID" error is shown
      expect(find.text('Please specify your primary clinic branch ID'), findsNothing);
    });
  });

  group('DAY 4 — Auth Persistence & Profile Screen Tests', () {
    testWidgets('AuthGate renders splash flow when unauthenticated', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          ),
        ),
      );

      // Unauthenticated cold start shows branding splash flow
      expect(find.text('VetCare'), findsOneWidget);
      expect(find.text('Centralized Veterinary Medical Records'), findsOneWidget);

      // Settle splash navigation timer to Login
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders user details and Log Out button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const ProfileScreen(),
          ),
        ),
      );

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Account Details'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Multi-Clinic Sync'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Log Out'), findsOneWidget);

      final deleteBtn = find.text('Delete Account');
      await tester.ensureVisible(deleteBtn);
      expect(deleteBtn, findsOneWidget);
      expect(find.text('Danger Zone'), findsOneWidget);
    });

    testWidgets('OwnerHomeScreen includes working profile and logout actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const OwnerHomeScreen(),
          ),
        ),
      );

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.byIcon(Icons.person_outline)),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.logout_outlined), findsOneWidget);
    });

    test('branchId is strictly null for owner role in UserModel mapping', () {
      final ownerUser = UserModel(
        id: 'owner_123',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'owner',
        branchId: null,
        createdAt: DateTime(2026, 9, 15),
      );

      final map = ownerUser.toMap();
      expect(map['branchId'], isNull);
      expect(map['role'], equals('owner'));
      expect(map['name'], equals('John Doe'));
      expect(map['email'], equals('john@example.com'));
      expect(map.containsKey('createdAt'), isTrue);
    });
  });
}
