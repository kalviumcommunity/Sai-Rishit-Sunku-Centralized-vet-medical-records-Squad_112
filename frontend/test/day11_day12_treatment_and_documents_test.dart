import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare/models/models.dart';
import 'package:vetcare/screens/pet/documents_screen.dart';
import 'package:vetcare/screens/vet/add_treatment_screen.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/services/medical_records_service.dart';
import 'package:vetcare/services/storage_service.dart';

class MockAuthService extends ChangeNotifier implements AuthService {
  UserModel? _mockUserModel;

  void setMockUser(UserModel? user) {
    _mockUserModel = user;
    notifyListeners();
  }

  @override
  UserModel? get currentUserModel => _mockUserModel;

  @override
  bool get isAuthenticated => _mockUserModel != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final testPet = PetModel(
    id: 'pet_bruno_001',
    name: 'Bruno',
    species: 'Dog',
    breed: 'Golden Retriever',
    gender: 'male',
    dateOfBirth: DateTime(2022, 4, 10),
    microchipId: '#VT-8820',
    ownerId: 'user_rishi_owner',
    weightKg: 31.5,
    createdAt: DateTime(2026, 9, 2),
  );

  final mockVetUser = UserModel(
    id: 'user_dr_sharma',
    email: 'dr.sharma@vetcare.com',
    name: 'Dr. Sharma',
    role: 'vet',
    branchId: 'branch_koramangala',
    createdAt: DateTime(2026, 8, 5),
  );

  Widget createTestWidget(Widget child, {UserModel? user}) {
    final mockAuth = MockAuthService();
    mockAuth.setMockUser(user ?? mockVetUser);

    return ChangeNotifierProvider<AuthService>.value(
      value: mockAuth,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('DAY 11 — Add Treatment Screen & Protocol Presets Tests', () {
    testWidgets('renders header, pet quick-info card, checked-in pill, and sync banner', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(AddTreatmentScreen(pet: testPet)));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Log Clinical Treatment'), findsOneWidget);

      // Pet quick-info card with breed, age, and weight
      expect(find.text('Bruno'), findsOneWidget);
      expect(find.text('Checked In'), findsOneWidget);
      expect(find.textContaining('Golden Retriever'), findsOneWidget);
      expect(find.textContaining('31.5 kg'), findsOneWidget);

      // Presets header
      expect(find.text('Quick Protocol Presets'), findsOneWidget);

      // Static network sync banner
      expect(find.text('Changes sync automatically to all VetCare clinics.'), findsOneWidget);

      // Save button
      expect(find.text('Save Treatment Record'), findsOneWidget);
    });

    testWidgets('Quick Protocol Presets correctly auto-fills Diagnosis and Medication fields', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(AddTreatmentScreen(pet: testPet)));
      await tester.pumpAndSettle();

      // Find "Ear Flush & Drops" preset chip
      final earPresetChip = find.widgetWithText(ChoiceChip, 'Ear Flush & Drops');
      expect(earPresetChip, findsOneWidget);

      // Tap preset
      await tester.tap(earPresetChip);
      await tester.pumpAndSettle();

      // Verify Diagnosis is populated from lookup table inside EditableText
      expect(
        find.byWidgetPredicate(
          (w) => w is EditableText && w.controller.text.contains('Otitis Externa'),
        ),
        findsOneWidget,
      );
      // Verify Medication & Dosage is populated
      expect(
        find.byWidgetPredicate(
          (w) => w is EditableText && w.controller.text.contains('Otomax Otic Ointment'),
        ),
        findsOneWidget,
      );

      // Now tap "Annual Booster" preset chip
      final boosterPresetChip = find.widgetWithText(ChoiceChip, 'Annual Booster');
      expect(boosterPresetChip, findsOneWidget);

      await tester.tap(boosterPresetChip);
      await tester.pumpAndSettle();

      // Verify fields updated
      expect(
        find.byWidgetPredicate(
          (w) => w is EditableText && w.controller.text.contains('Preventive Healthcare Examination'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is EditableText && w.controller.text.contains('DHPP + Rabies Booster'),
        ),
        findsOneWidget,
      );
    });

    test('addTreatment service call auto-attaches vetId, branchId, and status: active', () async {
      final service = MedicalRecordsService();
      final now = DateTime.now();

      final treatment = await service.addTreatment(
        petId: testPet.id,
        diagnosis: 'Otitis Externa',
        medication: 'Otomax BID x 10d',
        notes: 'Ears flushed.',
        treatmentDate: now,
        followUpDate: now.add(const Duration(days: 14)),
        branchId: 'branch_koramangala',
        vetId: 'user_dr_sharma',
      );

      expect(treatment.petId, 'pet_bruno_001');
      expect(treatment.status, 'active');
      expect(treatment.vetId, 'user_dr_sharma');
      expect(treatment.branchId, 'branch_koramangala');
      expect(treatment.branchName, 'VetCare Central - Koramangala');
      expect(treatment.diagnosis, 'Otitis Externa');
    });
  });

  group('DAY 12 — Documents Screen & Storage Service Tests', () {
    testWidgets('renders bone icon header, 15MB dashed upload box, and softened security banner', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(DocumentsScreen(pet: testPet)));
      await tester.pumpAndSettle();

      // Header title with pet name
      expect(find.text("Bruno's Documents"), findsOneWidget);

      // Dashed-border upload area with 15MB specification
      expect(find.text('Upload Prescription / X-ray'), findsOneWidget);
      expect(find.text('PDF, JPG or PNG (up to 15MB)'), findsOneWidget);
      expect(find.text('Select Document'), findsOneWidget);

      // Softened copy banner (not claiming end-to-end client encryption)
      expect(find.text('Securely Stored & Synced across VetCare Clinics'), findsOneWidget);

      // List of uploaded records
      expect(find.text('Uploaded Records & Scans'), findsOneWidget);
      expect(find.textContaining('CBC_Complete_Blood_Panel.pdf'), findsOneWidget);
      expect(find.textContaining('Abdominal_Radiograph_XRay.png'), findsOneWidget);

      // Action icons
      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
      expect(find.byIcon(Icons.download_rounded), findsWidgets);
    });

    test('StorageService rejects files exceeding 15MB threshold', () async {
      final storageService = StorageService();
      final oversizedBytes = Uint8List(16 * 1024 * 1024); // 16MB

      expect(
        () async => await storageService.uploadDocument(
          petId: 'pet_bruno_001',
          fileName: 'oversized_scan.pdf',
          bytes: oversizedBytes,
          branchId: 'branch_koramangala',
          uploadedBy: 'user_dr_sharma',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('StorageService persists and returns uploaded document metadata', () async {
      final storageService = StorageService();
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final doc = await storageService.uploadDocument(
        petId: 'pet_bruno_001',
        fileName: 'Urinalysis_Report.pdf',
        bytes: testBytes,
        branchId: 'branch_koramangala',
        uploadedBy: 'user_dr_sharma',
      );

      expect(doc.petId, 'pet_bruno_001');
      expect(doc.fileName, 'Urinalysis_Report.pdf');
      expect(doc.fileUrl.isNotEmpty, true);
      expect(doc.uploadedBy, 'user_dr_sharma');
      expect(doc.branchId, 'branch_koramangala');
      expect(doc.isPdf, true);

      final petDocs = await storageService.fetchPetDocuments('pet_bruno_001');
      expect(petDocs.any((d) => d.fileName == 'Urinalysis_Report.pdf'), true);
    });
  });
}
