import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare/screens/auth/login_screen.dart';
import 'package:vetcare/screens/main_navigation_shell.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/utils/constants.dart';
import 'package:vetcare/widgets/limelight_nav.dart';

void main() {
  group('MainNavigationShell & Limelight Navigation Tests', () {
    testWidgets('MainNavigationShell displays Home screen content and LimelightNavBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const MainNavigationShell(initialIndex: 0),
          ),
        ),
      );

      // Verify Home Screen Content is clearly visible
      expect(find.text('My Pets'), findsOneWidget);
      expect(find.text('Pet Dashboard'), findsOneWidget);
      expect(find.text('Milo'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Quick Navigation'), 100);
      expect(find.text('Quick Navigation'), findsOneWidget);

      // Verify LimelightNavBar is present with 5 tabs
      expect(find.byType(LimelightNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Add Pet'), findsOneWidget);
      expect(find.text('Clinics'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Tapping Records tab switches to Pet Profile view within shell', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const MainNavigationShell(initialIndex: 0),
          ),
        ),
      );

      // Tap on Records tab in the LimelightNavBar
      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();

      // Verify Records (PetProfileScreen) content is now active
      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Vaccinations'), findsOneWidget);
      expect(find.text('Medical Documents & Lab Reports'), findsOneWidget);

      // Navigation bar remains visible
      expect(find.byType(LimelightNavBar), findsOneWidget);
    });

    testWidgets('Tapping Add Pet tab switches to AddPetScreen view without back button in shell', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const MainNavigationShell(initialIndex: 0),
          ),
        ),
      );

      // Tap on Add Pet tab
      await tester.tap(find.text('Add Pet'));
      await tester.pumpAndSettle();

      // Verify Add Pet screen content
      expect(find.text('Pet Name *'), findsOneWidget);
      expect(find.text('Species *'), findsOneWidget);
      expect(find.text('Add Photo'), findsOneWidget);

      // Since it is embedded in navigation, BackButton is hidden
      expect(find.byType(BackButton), findsNothing);

      // Navigation bar remains visible
      expect(find.byType(LimelightNavBar), findsOneWidget);
    });

    testWidgets('LoginScreen does NOT render the LimelightNavBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Verify Login Screen elements
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('LOG IN'), findsOneWidget);

      // Crucial: Ensure LimelightNavBar is absent on Login
      expect(find.byType(LimelightNavBar), findsNothing);
    });

    testWidgets('Veterinarian role displays clinical tabs and Admin Hub in LimelightNavBar', (WidgetTester tester) async {
      final authService = AuthService();
      await authService.switchRole('vet');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>.value(
            value: authService,
            child: const MainNavigationShell(initialIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Veterinarian/Admin Nav Items
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Follow-ups'), findsOneWidget);
      expect(find.text('Record Care'), findsOneWidget);
      expect(find.text('Admin Hub'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify Tab 0 is Patients (VetSearchScreen)
      expect(find.text('Cross-Branch Pet Search'), findsOneWidget);

      // Tap Admin Hub
      await tester.tap(find.text('Admin Hub'));
      await tester.pumpAndSettle();

      // Verify Admin Screen is displayed
      expect(find.text('Admin Network Console'), findsOneWidget);
      expect(find.text('Branches'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, '+ Add Branch'), findsOneWidget);
    });
  });
}
