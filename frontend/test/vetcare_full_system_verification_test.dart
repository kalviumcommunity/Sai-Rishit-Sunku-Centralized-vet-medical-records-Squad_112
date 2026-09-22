import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vetcare/models/models.dart';
import 'package:vetcare/screens/admin/admin_screen.dart';
import 'package:vetcare/screens/auth/login_screen.dart';
import 'package:vetcare/screens/owner/owner_home_screen.dart';
import 'package:vetcare/screens/pet/pet_profile_screen.dart';
import 'package:vetcare/screens/vet/vet_followups_screen.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/services/medical_records_service.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group(
      'VETCARE FULL SYSTEM VERIFICATION — NO PLACEHOLDERS & COMPLETE TEST DATA',
      () {
    testWidgets(
        '1. Auth & Touchless Lobby Check-in: Working Queue Pass generation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll until Touchless Check-in card is visible
      await tester.scrollUntilVisible(
        find.widgetWithText(ElevatedButton, 'Check In'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Arrived at the Clinic?'), findsOneWidget);
      expect(
          find.text('Tap for fast touchless lobby check-in'), findsOneWidget);

      // Tap Check In button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Check In'));
      await tester.pumpAndSettle();

      // Verify the interactive Lobby Check-in Bottom Sheet opens
      expect(find.text('Touchless Lobby Check-In'), findsOneWidget);
      expect(find.text('Confirm Arrival & Get Queue Pass'), findsOneWidget);

      // Tap Confirm Arrival & Get Queue Pass
      await tester.tap(find.text('Confirm Arrival & Get Queue Pass'));
      await tester.pumpAndSettle();

      // Verify Priority Arrival Pass is issued with queue token
      expect(find.text('Check-In Confirmed!'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Dismiss bottom sheet
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('2. Owner Home Screen: Working Notifications & Alerts Sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const OwnerHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the notification bell icon button
      final notificationBtn = find.byTooltip('Notifications');
      expect(notificationBtn, findsOneWidget);
      await tester.tap(notificationBtn);
      await tester.pumpAndSettle();

      // Verify Notifications bottom sheet opened with active alerts
      expect(find.text('Clinic Notifications & Alerts'), findsOneWidget);
      expect(find.text('Cross-Clinic Sync Active'), findsOneWidget);
      expect(find.text('Follow-up Due in 3 Days'), findsOneWidget);

      // Dismiss alerts
      await tester.tap(find.text('Dismiss Alerts'));
      await tester.pumpAndSettle();
      expect(find.text('Clinic Notifications & Alerts'), findsNothing);
    });

    testWidgets('3. Pet Profile Screen: Working Edit Pet Bottom Sheet',
        (WidgetTester tester) async {
      final testPet = PetModel(
        id: 'pet_bruno_test',
        name: 'Bruno',
        species: 'Dog',
        breed: 'Golden Retriever',
        gender: 'male',
        dateOfBirth: DateTime(2022, 4, 15),
        microchipId: '985141002345678',
        ownerId: 'owner_rishi',
        weightKg: 31.5,
        createdAt: DateTime(2022, 4, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PetProfileScreen(initialPet: testPet),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Bruno is displayed on the Hero Card
      expect(find.text('Bruno'), findsOneWidget);
      expect(find.textContaining('Golden Retriever'), findsOneWidget);

      // Find and tap Edit Pet button
      final editBtn = find.byTooltip('Edit Pet');
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      // Verify Edit Details modal opens
      expect(find.text("Edit Bruno's Details"), findsOneWidget);
      expect(find.text('Save Details'), findsOneWidget);

      // Enter updated weight
      final weightField = find.widgetWithText(TextFormField, 'Weight (kg)');
      await tester.enterText(weightField, '32.0');

      // Save details
      await tester.tap(find.text('Save Details'));
      await tester.pumpAndSettle();

      // Verify success SnackBar
      expect(find.text("Updated Bruno's profile details!"), findsOneWidget);
    });

    testWidgets('4. Vet Followups: Working Interactive Owner Messaging Sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VetFollowupsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Follow-ups list renders
      expect(find.text('Cross-Branch Access'), findsOneWidget);
      expect(find.text('Due This Week'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);

      // Tap the chat bubble to open owner messaging sheet
      await tester.tap(find.byIcon(Icons.chat_bubble_outline).first);
      await tester.pumpAndSettle();

      // Verify interactive messaging sheet
      expect(find.text('Send Owner Update'), findsOneWidget);
      expect(find.text('Follow-up Care Note / Reminder SMS'), findsOneWidget);

      // Tap Send Owner Update
      await tester.tap(find.text('Send Owner Update'));
      await tester.pumpAndSettle();

      // Verify message dispatched confirmation
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets(
        '5. Admin Dashboard: Complete Stats, Hub Tags, Add Branch & Audit Log',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const AdminScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Stats Grid
      expect(find.text('Admin Network Console'), findsOneWidget);
      expect(find.text('Branches'), findsOneWidget);
      expect(find.text('Veterinarians'), findsOneWidget);
      expect(find.text('Total Pets'), findsOneWidget);
      expect(find.text('Pet Owners'), findsOneWidget);

      // Verify Cosmetic Replication status bar
      expect(
          find.text('Cross-Clinic Replication: 100% Synced'), findsOneWidget);

      // Tap + Add Branch
      await tester.tap(find.widgetWithText(ElevatedButton, '+ Add Branch'));
      await tester.pumpAndSettle();

      // Verify Add Branch sheet and validation
      expect(find.text('Add New Clinic Branch'), findsOneWidget);
      await tester.tap(find.text('Save & Connect Branch'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a branch name'), findsOneWidget);

      // Enter valid branch info
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'VetCare HSR Layout');
      await tester.enterText(textFields.at(1), '27th Main, Sector 1, HSR');
      await tester.enterText(textFields.at(2), '+91 80 4455 6677');

      // Save branch
      await tester.tap(find.text('Save & Connect Branch'));
      await tester.pumpAndSettle();

      // Verify newly created branch appears in list
      expect(find.text('VetCare HSR Layout'), findsOneWidget);

      // Scroll to verify HIPAA Audit Log
      await tester.scrollUntilVisible(
        find.text('HIPAA & Vet-Audit Log'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('HIPAA & Vet-Audit Log'), findsOneWidget);
    });

    testWidgets(
        '6. Complete Multi-Clinic Story: Rishi -> Bruno -> Koramangala -> Whitefield',
        (WidgetTester tester) async {
      final recordsService = MedicalRecordsService();

      // 1. Owner Rishi registers pet Bruno
      final bruno = PetModel(
        id: 'e2e_bruno_story',
        name: 'Bruno',
        nameLower: 'bruno',
        species: 'Dog',
        breed: 'Golden Retriever',
        gender: 'male',
        dateOfBirth: DateTime(2022, 4, 15),
        microchipId: '985141002345678',
        ownerId: 'e2e_owner_rishi',
        weightKg: 31.5,
        createdAt: DateTime(2022, 4, 15),
      );
      await recordsService.registerPet(bruno);

      // 2. Koramangala vet logs ear infection treatment with 3-day follow-up
      await recordsService.addTreatment(
        petId: bruno.id,
        vetId: 'vet_priya_sharma',
        branchId: 'branch_koramangala',
        treatmentDate: DateTime.now(),
        diagnosis: 'Otitis Externa (Ear Infection)',
        medication: 'Otomax drops BID for 7 days',
        notes: 'Cleaned bilateral canals. Swab cytology confirmed yeast.',
        followUpDate: DateTime.now().add(const Duration(days: 3)),
      );

      // 3. Whitefield vet searches Bruno by name
      final searchResults = await recordsService.searchPets(query: 'Bruno');
      expect(searchResults.any((res) => res.pet.id == bruno.id), isTrue);

      // 4. Whitefield vet views Bruno unified medical records
      final unifiedRecords = await recordsService.getUnifiedRecords(bruno.id);
      expect(
          unifiedRecords.any((rec) =>
              rec.diagnosis == 'Otitis Externa (Ear Infection)' ||
              rec.title.contains('Otitis Externa')),
          isTrue);
      expect(unifiedRecords.any((rec) => rec.branchId == 'branch_koramangala'),
          isTrue);

      // 5. Whitefield vet checks upcoming followups worklist
      final followups = await recordsService.fetchUpcomingFollowups(
          vetBranchId: 'branch_whitefield');
      expect(followups.any((fu) => fu.petId == bruno.id), isTrue);
    });
  });
}
