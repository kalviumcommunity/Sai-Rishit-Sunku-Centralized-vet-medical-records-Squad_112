import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare/routes/app_routes.dart';
import 'package:vetcare/screens/vet/vet_followups_screen.dart';
import 'package:vetcare/screens/vet/vet_search_screen.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/services/medical_records_service.dart';
import 'package:vetcare/utils/constants.dart';

void main() {
  group('DAY 9 — Vet Search Pets & Cross-Branch Discovery Tests', () {
    test('searchPets service accurately computes cross-branch counts and filters', () async {
      final service = MedicalRecordsService();

      // All pets
      final allResults = await service.searchPets(query: '', tab: 'all');
      expect(allResults.length, greaterThanOrEqualTo(5));

      // Specific pet search: Bella (cross-branch pet with records from Westside and Central Metro Hub)
      final bellaSearch = await service.searchPets(query: 'Bella', tab: 'all');
      expect(bellaSearch.length, 1);
      final bella = bellaSearch.first;
      expect(bella.pet.name, 'Bella');
      expect(bella.pet.breed, 'Beagle');
      expect(bella.ownerName, 'David Miller');
      expect(bella.distinctBranchCount, 2); // 2 distinct branches
      expect(bella.branches, contains('Westside Branch'));
      expect(bella.branches, contains('Central Metro Hub'));

      // Specific pet search: Oliver (cross-branch pet with records from 3 branches)
      final oliverSearch = await service.searchPets(query: 'Oliver', tab: 'all');
      expect(oliverSearch.length, 1);
      expect(oliverSearch.first.distinctBranchCount, 3);
    });

    testWidgets('VetSearchScreen renders 3 tabs, search bar, filter chips, branch-count badge, and sync banner', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const VetSearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Three Segmented Tabs
      expect(find.text('All Pets'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('My Branch'), findsOneWidget);

      // 2. Search Bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search pets by name, microchip, or owner...'), findsOneWidget);

      // 3. Quick Filter Chips (Client-Side)
      expect(find.text('Dogs'), findsOneWidget);
      expect(find.text('Cats'), findsOneWidget);
      expect(find.text('Urgent Care'), findsOneWidget);
      expect(find.text('Due for Booster'), findsOneWidget);

      // 4. Result cards with branch-count badges (Proof of cross-branch records!)
      expect(find.text('Milo'), findsOneWidget);
      expect(find.text('Bella'), findsOneWidget);
      expect(find.text('Oliver'), findsOneWidget);
      expect(find.text('2 branches'), findsWidgets);
      expect(find.text('3 branches'), findsWidgets);

      // 5. Static "Universal Hospital Sync" Banner
      expect(find.text('Universal Hospital Sync'), findsOneWidget);
      expect(find.text('Weekly Adherence: 92%'), findsOneWidget);

      // Client-side filtering: tap "Cats" chip
      await tester.tap(find.text('Cats'));
      await tester.pumpAndSettle();

      // Should show cats (Oliver, Cleo) and filter out dogs (Milo, Bella)
      expect(find.text('Oliver'), findsOneWidget);
      expect(find.text('Cleo'), findsOneWidget);
      expect(find.text('Milo'), findsNothing);
      expect(find.text('Bella'), findsNothing);

      // Reset filter
      await tester.tap(find.text('Reset filters'));
      await tester.pumpAndSettle();
      expect(find.text('Milo'), findsOneWidget);

      // Search query test: type "Bella"
      await tester.enterText(find.byType(TextField), 'Bella');
      await tester.pumpAndSettle();

      // EditableText + Result Card = 2 widgets with text "Bella"
      expect(find.text('Bella'), findsNWidgets(2));
      expect(find.text('Owner: David Miller'), findsOneWidget);
      expect(find.text('2 branches'), findsOneWidget);
      expect(find.text('Milo'), findsNothing);
    });
  });

  group('DAY 10 — Vet Today\'s Follow-ups & Cross-Branch Worklist Tests', () {
    test('fetchUpcomingFollowups returns cross-branch treatments across multiple clinics', () async {
      final service = MedicalRecordsService();
      final followups = await service.fetchUpcomingFollowups();

      expect(followups.length, greaterThanOrEqualTo(4));

      // Proves records originated from different branches
      final branchOrigins = followups.map((f) => f.originBranchName).toSet();
      expect(branchOrigins.contains('Westside Branch'), isTrue);
      expect(branchOrigins.contains('Downtown Branch'), isTrue);
      expect(branchOrigins.contains('Central Metro Hub'), isTrue);
    });

    testWidgets('VetFollowupsScreen renders Cross-Branch banner, filters, multi-branch worklist, and chat icon', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const VetFollowupsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. "Cross-Branch Access" Banner
      expect(find.text('Cross-Branch Access'), findsOneWidget);
      expect(
        find.textContaining('Centralized clinical worklist'),
        findsOneWidget,
      );

      // 2. Quick Filter Tabs
      expect(find.textContaining('All ('), findsOneWidget);
      expect(find.textContaining('Urgent ('), findsOneWidget);
      expect(find.textContaining('Post-Surgery ('), findsOneWidget);
      expect(find.textContaining('Medication Review ('), findsOneWidget);

      // 3. "Due This Week" Header
      expect(find.text('Due This Week'), findsOneWidget);

      // 4. Multi-Branch Origins Displayed
      expect(find.text('Branch: Westside Branch'), findsWidgets);
      expect(find.text('Branch: Downtown Branch'), findsWidgets);
      expect(find.text('Branch: Central Metro Hub'), findsWidgets);

      // Appointment Times
      expect(find.text('Today, 10:30 AM'), findsOneWidget);
      expect(find.text('Today, 02:00 PM'), findsOneWidget);

      // 5. Visual-only Chat Icon Placeholder
      expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);

      // Tapping chat icon displays the visual placeholder message
      await tester.tap(find.byIcon(Icons.chat_bubble_outline).first);
      await tester.pumpAndSettle();
      expect(find.text('Owner messaging channel is a placeholder.'), findsOneWidget);

      // Filter test: tap "Post-Surgery (2)" tab
      await tester.tap(find.text('Post-Surgery (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Bella'), findsOneWidget);
      expect(find.text('Rocky'), findsOneWidget);
      expect(find.text('Milo'), findsNothing); // Milo is urgent dermatitis, not post-surgery
    });
  });
}
