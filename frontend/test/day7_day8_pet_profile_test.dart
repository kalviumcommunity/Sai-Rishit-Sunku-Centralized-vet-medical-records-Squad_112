import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare/models/models.dart';
import 'package:vetcare/screens/pet/pet_profile_screen.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/services/medical_records_service.dart';
import 'package:vetcare/utils/constants.dart';

void main() {
  group('DAY 7 & DAY 8 — Medical Records Calculation & Rules Logic Tests', () {
    test('calculateDistinctBranches correctly counts unique clinic branches', () {
      final service = MedicalRecordsService();
      final records = [
        UnifiedMedicalRecord(
          id: '1',
          type: MedicalRecordType.treatment,
          title: 'Ear Infection',
          branchId: 'b1',
          branchName: 'Downtown Branch',
          vetId: 'v1',
          vetName: 'Dr. Sarah',
          date: DateTime.now(),
          rawStatus: 'resolved',
        ),
        UnifiedMedicalRecord(
          id: '2',
          type: MedicalRecordType.vaccination,
          title: 'Rabies',
          branchId: 'b2',
          branchName: 'Westside Branch',
          vetId: 'v2',
          vetName: 'Dr. Michael',
          date: DateTime.now(),
          rawStatus: 'active',
        ),
        UnifiedMedicalRecord(
          id: '3',
          type: MedicalRecordType.checkup,
          title: 'Dental Exam',
          branchId: 'b1',
          branchName: 'Downtown Branch',
          vetId: 'v1',
          vetName: 'Dr. Sarah',
          date: DateTime.now(),
          rawStatus: 'completed',
        ),
      ];

      final distinctCount = service.calculateDistinctBranches(records);
      expect(distinctCount, 2); // Downtown and Westside
    });

    test('medical history status tag computation follows documented Day 7 rules', () {
      final now = DateTime.now();

      // Treatment rule: resolved status or past followUpDate => "Resolved"
      final treatment = UnifiedMedicalRecord(
        id: 't1',
        type: MedicalRecordType.treatment,
        title: 'Allergy Flush',
        branchId: 'b1',
        branchName: 'Downtown Branch',
        vetId: 'v1',
        vetName: 'Dr. Sarah',
        date: now.subtract(const Duration(days: 30)),
        followUpDate: now.subtract(const Duration(days: 5)),
        rawStatus: 'resolved',
      );
      expect(treatment.statusTag, 'Resolved');

      // Vaccination rule: [X] Year Valid computed from dateGiven & nextDueDate gap
      final vac3Year = UnifiedMedicalRecord(
        id: 'v1',
        type: MedicalRecordType.vaccination,
        title: 'Rabies 3-Year',
        branchId: 'b2',
        branchName: 'Westside Branch',
        vetId: 'v2',
        vetName: 'Dr. Michael',
        date: DateTime(2024, 1, 1),
        nextDueDate: DateTime(2027, 1, 1),
        rawStatus: 'active',
      );
      expect(vac3Year.statusTag, '3 Year Valid');

      final vac1Year = UnifiedMedicalRecord(
        id: 'v2',
        type: MedicalRecordType.vaccination,
        title: 'Bordetella',
        branchId: 'b1',
        branchName: 'Downtown Branch',
        vetId: 'v1',
        vetName: 'Dr. Sarah',
        date: DateTime(2025, 6, 1),
        nextDueDate: DateTime(2026, 6, 1),
        rawStatus: 'active',
      );
      expect(vac1Year.statusTag, '1 Year Valid');

      // Routine checkup rule: always "Completed"
      final checkup = UnifiedMedicalRecord(
        id: 'c1',
        type: MedicalRecordType.checkup,
        title: 'Routine Vitals Check',
        branchId: 'b1',
        branchName: 'Downtown Branch',
        vetId: 'v1',
        vetName: 'Dr. Sarah',
        date: now.subtract(const Duration(days: 60)),
        rawStatus: 'completed',
      );
      expect(checkup.statusTag, 'Completed');
    });

    test('Day 8 immunization status summary accurately computes up-to-date ratio', () {
      final service = MedicalRecordsService();
      final now = DateTime.now();

      final vaccines = [
        VaccinationModel(
          id: 'v1',
          petId: 'p1',
          vaccineName: 'Rabies 3-Year',
          dateGiven: now.subtract(const Duration(days: 100)),
          nextDueDate: now.add(const Duration(days: 900)), // Up to date
          vetId: 'v1',
          branchId: 'b1',
          notes: '',
          createdAt: now,
        ),
        VaccinationModel(
          id: 'v2',
          petId: 'p1',
          vaccineName: 'DHPP Booster',
          dateGiven: now.subtract(const Duration(days: 100)),
          nextDueDate: now.add(const Duration(days: 200)), // Up to date
          vetId: 'v1',
          branchId: 'b1',
          notes: '',
          createdAt: now,
        ),
        VaccinationModel(
          id: 'v3',
          petId: 'p1',
          vaccineName: 'Bordetella',
          dateGiven: now.subtract(const Duration(days: 100)),
          nextDueDate: now.add(const Duration(days: 250)), // Up to date
          vetId: 'v1',
          branchId: 'b1',
          notes: '',
          createdAt: now,
        ),
        VaccinationModel(
          id: 'v4',
          petId: 'p1',
          vaccineName: 'Leptospirosis',
          dateGiven: now.subtract(const Duration(days: 400)),
          nextDueDate: now.subtract(const Duration(days: 35)), // Overdue
          vetId: 'v1',
          branchId: 'b1',
          notes: '',
          createdAt: now,
        ),
      ];

      final summary = service.calculateImmunizationSummary(vaccines);
      expect(summary.upToDateCount, 3);
      expect(summary.totalCount, 4);
      expect(summary.summaryText, '3 of 4 Ready');
    });
  });

  group('DAY 7 — Pet Profile UI & Cross-Branch Verification Tests', () {
    testWidgets('renders hero card, orange ring avatar, chips, and cross-branch sync banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const PetProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pet Name
      expect(find.text('Milo'), findsOneWidget);

      // Breed & Microchip ID format: "[Breed] · Microchip #[ID]"
      expect(find.text('Golden Retriever \u00B7 Microchip #98514'), findsOneWidget);

      // Info Chips: Age / Weight / Gender
      expect(find.text('Age: '), findsOneWidget);
      expect(find.text('3 yrs'), findsOneWidget);
      expect(find.text('Weight: '), findsOneWidget);
      expect(find.text('28 kg'), findsOneWidget);
      expect(find.text('Gender: '), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);

      // Unified Cloud Record Banner with computed N metro branches
      expect(
        find.text('Unified Cloud Record \u2014 Synced across 2 metro branches'),
        findsOneWidget,
      );

      // Cross-branch records must show both branch names
      expect(find.textContaining('Downtown Branch'), findsWidgets);
      expect(find.textContaining('Westside Branch'), findsWidgets);

      // Subtitle format "[Branch Name] · [Vet Name]"
      expect(find.text('Downtown Branch \u00B7 Dr. Sarah Jenkins, DVM'), findsWidgets);
      expect(find.text('Westside Branch \u00B7 Dr. Michael Chang, DVM'), findsWidgets);

      // Status tags computed from real data
      expect(find.text('Resolved'), findsOneWidget);
      expect(find.text('3 Year Valid'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('1 Year Valid'), findsOneWidget);

      // "VIEW FULL HISTORY" button at bottom
      expect(find.text('VIEW FULL HISTORY'), findsOneWidget);
    });
  });

  group('DAY 8 — Dedicated Vaccinations Tab Tests', () {
    testWidgets('switching to Vaccinations tab shows immunization status, scheduled list, and + Add button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const PetProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Vaccinations segment tab
      await tester.tap(find.text('Vaccinations'));
      await tester.pumpAndSettle();

      // Immunization Status summary: "3 of 4 Ready"
      expect(find.text('Immunization Status'), findsOneWidget);
      expect(find.text('3 of 4 Ready'), findsOneWidget);

      // Scheduled Immunizations List
      expect(find.text('Scheduled Immunizations'), findsOneWidget);
      expect(find.text('Rabies 3-Year Vaccine'), findsOneWidget);
      expect(find.text('DHPP Booster'), findsOneWidget);
      expect(find.text('Bordetella Oral'), findsOneWidget);
      expect(find.text('Leptospirosis 4-Way'), findsOneWidget);

      // Status Pills: green "Up to date" and red "Overdue"
      expect(find.text('Up to date'), findsNWidgets(3));
      expect(find.text('Overdue'), findsOneWidget);

      // Overdue row has "Book Now" link
      expect(find.text('Book Now'), findsOneWidget);

      // "+ Add Vaccination" action button
      expect(find.text('+ Add Vaccination'), findsOneWidget);

      // Tap "Add Vaccination" FAB which opens the modal form
      await tester.tap(find.text('Add Vaccination'));
      await tester.pumpAndSettle();

      expect(find.text('+ Add Vaccination Record'), findsOneWidget);
      expect(find.text('Save Vaccination Record'), findsOneWidget);
    });
  });
}
