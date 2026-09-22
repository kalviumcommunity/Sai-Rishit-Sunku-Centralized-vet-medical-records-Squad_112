import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare/models/models.dart';
import 'package:vetcare/screens/admin/admin_screen.dart';
import 'package:vetcare/screens/auth/login_screen.dart';
import 'package:vetcare/screens/auth/signup_screen.dart';
import 'package:vetcare/screens/owner/add_pet_screen.dart';
import 'package:vetcare/services/admin_service.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/services/medical_records_service.dart';
import 'package:vetcare/utils/constants.dart';

void main() {
  group('DAY 13 — Admin Dashboard Tests', () {
    testWidgets('renders AdminScreen header, cosmetic replication status bar, and 2x2 stat grid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const AdminScreen(),
          ),
        ),
      );

      // Settle async futures
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify Header
      expect(find.text('Admin Network Console'), findsOneWidget);
      expect(find.text('Centralized Multi-Branch Mesh'), findsOneWidget);

      // Verify Cosmetic Replication Status Bar
      expect(find.text('Cross-Clinic Replication: 100% Synced'), findsOneWidget);
      expect(find.text('Multi-Region Central Mesh Active · Latency < 45ms'), findsOneWidget);
      expect(find.text('HEALTHY'), findsOneWidget);

      // Verify 2x2 Stat Cards
      expect(find.text('Branches'), findsOneWidget);
      expect(find.text('Veterinarians'), findsOneWidget);
      expect(find.text('Total Pets'), findsOneWidget);
      expect(find.text('Pet Owners'), findsOneWidget);

      // Verify Branch Directory Header & Add Branch Button
      expect(find.text('Clinic Branches'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, '+ Add Branch'), findsOneWidget);

      // Scroll until HIPAA & Vet-Audit Log Card is visible
      await tester.scrollUntilVisible(
        find.text('HIPAA & Vet-Audit Log'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Verify HIPAA & Vet-Audit Log Card
      expect(find.text('HIPAA & Vet-Audit Log'), findsOneWidget);
      expect(find.text('ADMIN EVENTS'), findsOneWidget);
    });

    test('AdminService manages stats, branches with counts, and audit logs', () async {
      final adminService = AdminService();

      // Stats calculation
      final stats = await adminService.fetchAdminStats();
      expect(stats.branchesCount, greaterThanOrEqualTo(5));
      expect(stats.hubsCount, greaterThanOrEqualTo(2));
      expect(stats.vetsCount, greaterThan(0));
      expect(stats.petsCount, greaterThan(0));
      expect(stats.ownersCount, greaterThan(0));

      // Branches with joined stats
      final branchesWithStats = await adminService.fetchBranchesWithStats();
      expect(branchesWithStats.isNotEmpty, isTrue);

      final koramangala = branchesWithStats.firstWhere((b) => b.branch.id == 'branch_koramangala');
      expect(koramangala.branch.isHub, isTrue);
      expect(koramangala.vetCount, greaterThanOrEqualTo(4));
      expect(koramangala.recordCount, greaterThanOrEqualTo(30));

      // Adding a new branch
      final newBranch = await adminService.addBranch(
        name: 'VetCare Indiranagar Satellite',
        address: '100ft Road, Indiranagar, Bengaluru',
        phone: '+91 80 4455 6677',
        isHub: false,
      );

      expect(newBranch.name, equals('VetCare Indiranagar Satellite'));
      expect(newBranch.isHub, isFalse);

      // Verify audit logs updated with new action
      final logs = await adminService.fetchAdminAuditLogs();
      expect(logs.any((l) => l.action == 'Branch Created' && l.details.contains('Indiranagar')), isTrue);
    });
  });

  group('DAY 14 — Form Validation & Error States Tests', () {
    testWidgets('LoginScreen shows inline validation error on empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const LoginScreen(),
          ),
        ),
      );

      final loginBtn = find.widgetWithText(ElevatedButton, 'LOG IN');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expect inline error messages
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('SignupScreen shows inline validation error on invalid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const SignupScreen(),
          ),
        ),
      );

      final signupBtn = find.widgetWithText(ElevatedButton, 'SIGN UP');
      await tester.ensureVisible(signupBtn);
      await tester.tap(signupBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expect inline error messages
      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('AddPetScreen validates pet name field with inline error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const AddPetScreen(),
          ),
        ),
      );

      final saveBtn = find.widgetWithText(ElevatedButton, 'Save Pet Profile');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();

      expect(find.text('Please enter pet name.'), findsOneWidget);
    });
  });

  group('DAY 15 — End-to-End Core Story Verification Tests', () {
    test('E2E Flow: Rishi signs up -> adds Bruno -> Koramangala vet treats -> Whitefield vet searches & sees follow-up',
        () async {
      final medicalService = MedicalRecordsService();
      final now = DateTime.now();

      // Step 1: Owner "Rishi" signs up
      final rishiUser = UserModel(
        id: 'user_rishi_01',
        name: 'Rishi',
        email: 'rishi@example.com',
        role: 'owner',
        createdAt: now,
      );
      expect(rishiUser.role, equals('owner'));
      expect(rishiUser.branchId, isNull);

      // Step 2: Rishi adds pet "Bruno"
      final bruno = PetModel(
        id: 'pet_bruno_e2e_${now.millisecondsSinceEpoch}',
        name: 'Bruno',
        species: 'Dog',
        breed: 'Boxer',
        gender: 'male',
        dateOfBirth: DateTime(now.year - 3, now.month, now.day),
        microchipId: '98514100998877',
        ownerId: rishiUser.id,
        weightKg: 30.5,
        createdAt: now,
      );

      await medicalService.registerPet(bruno);
      expect(medicalService.petsNotifier.value.any((p) => p.name == 'Bruno'), isTrue);

      // Step 3: Vet at Koramangala branch logs treatment for Bruno with follow-up in the coming week
      final followUpIn3Days = now.add(const Duration(days: 3));
      final koramangalaTreatment = await medicalService.addTreatment(
        petId: bruno.id,
        diagnosis: 'Bilateral Otitis Externa & Ear Flushing',
        medication: 'Otomax Otic Suspension BID x 10d',
        notes: 'Cytology shows mixed bacterial infection. Cleaned external canal thoroughly.',
        treatmentDate: now,
        followUpDate: followUpIn3Days,
        branchId: 'branch_koramangala',
        vetId: 'vet_sarah',
        branchName: 'VetCare Central - Koramangala',
        vetName: 'Dr. Sarah Jenkins, DVM',
      );

      expect(koramangalaTreatment.petId, equals(bruno.id));
      expect(koramangalaTreatment.status, equals('active'));
      expect(koramangalaTreatment.branchName, equals('VetCare Central - Koramangala'));

      // Step 4: A different vet at Whitefield branch searches "Bruno"
      final whitefieldVetSearchResults = await medicalService.searchPets(
        query: 'Bruno',
        tab: 'all',
        vetBranchId: 'branch_whitefield',
      );

      expect(whitefieldVetSearchResults.isNotEmpty, isTrue);
      final brunoSearchResult = whitefieldVetSearchResults.firstWhere((r) => r.pet.id == bruno.id);
      expect(brunoSearchResult.pet.name, equals('Bruno'));
      expect(brunoSearchResult.branches.contains('VetCare Central - Koramangala'), isTrue);

      // Step 5: Whitefield vet inspects Bruno's Unified Medical Records
      final brunoRecords = await medicalService.getUnifiedRecords(bruno.id);
      expect(brunoRecords.isNotEmpty, isTrue);

      final otitisRecord = brunoRecords.firstWhere((r) => r.id == koramangalaTreatment.id);
      expect(otitisRecord.title, equals('Bilateral Otitis Externa & Ear Flushing'));
      expect(otitisRecord.branchName, equals('VetCare Central - Koramangala'));
      expect(otitisRecord.vetName, equals('Dr. Sarah Jenkins, DVM'));
      expect(otitisRecord.followUpDate, equals(followUpIn3Days));

      // Step 6: Whitefield vet checks "Today's Follow-ups" list for the network
      final followups = await medicalService.fetchUpcomingFollowups(
        vetBranchId: 'branch_whitefield',
      );

      expect(followups.isNotEmpty, isTrue);
      final brunoFollowup = followups.firstWhere((f) => f.petId == bruno.id);
      expect(brunoFollowup.petName, equals('Bruno'));
      expect(brunoFollowup.originBranchName, equals('VetCare Central - Koramangala'));
      expect(brunoFollowup.diagnosis, contains('Otitis Externa'));
      expect(brunoFollowup.followUpDate.isAfter(now), isTrue);
    });
  });
}
