import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare/models/treatment_model.dart';
import 'package:vetcare/models/vaccination_model.dart';

void main() {
  group('TreatmentModel Serialization & Lifecycle Tests', () {
    test('toMap and fromMap should round-trip correctly', () {
      final tDate = DateTime(2026, 9, 10, 10, 0);
      final fDate = DateTime(2026, 9, 24, 10, 0);
      final cDate = DateTime(2026, 9, 10, 10, 30);

      final treatment = TreatmentModel(
        id: 'trt_001',
        petId: 'pet_milo_001',
        diagnosis: 'Acute Gastroenteritis',
        medication: 'Metronidazole 250mg BID x 7d',
        notes: 'Mild dehydration noted. Follow up in 14 days.',
        treatmentDate: tDate,
        followUpDate: fDate,
        status: 'active',
        vetId: 'vet_sarah_123',
        branchId: 'branch_central_01',
        createdAt: cDate,
      );

      final map = treatment.toMap();
      expect(map['petId'], 'pet_milo_001');
      expect(map['diagnosis'], 'Acute Gastroenteritis');
      expect(map['status'], 'active');
      expect(map['vetId'], 'vet_sarah_123');
      expect(map['branchId'], 'branch_central_01');
      expect(map['followUpDate'], isA<Timestamp>());

      final parsed = TreatmentModel.fromMap(map, 'trt_001');
      expect(parsed.id, 'trt_001');
      expect(parsed.isActive, isTrue);
      expect(parsed.isResolved, isFalse);
      expect(parsed.hasFollowUp, isTrue);
      expect(parsed.treatmentDate, tDate);
      expect(parsed.followUpDate, fDate);
    });

    test('copyWith updates status to resolved', () {
      final treatment = TreatmentModel(
        id: 'trt_002',
        petId: 'pet_002',
        diagnosis: 'Otitis Externa',
        medication: 'Otic drops',
        notes: 'Ear cleaning done',
        treatmentDate: DateTime(2026, 8, 1),
        followUpDate: null,
        status: 'active',
        vetId: 'vet_1',
        branchId: 'branch_1',
        createdAt: DateTime(2026, 8, 1),
      );

      final resolved = treatment.copyWith(status: 'resolved');
      expect(resolved.isResolved, isTrue);
      expect(resolved.isActive, isFalse);
    });
  });

  group('VaccinationModel Client-Side Validity Tests', () {
    test('dynamic validity and duration computations', () {
      final now = DateTime.now();
      final givenDate = now.subtract(const Duration(days: 100));
      // 1 year valid vaccine due in ~265 days
      final futureDueDate = now.add(const Duration(days: 265));

      final activeVaccine = VaccinationModel(
        id: 'vac_001',
        petId: 'pet_milo_001',
        vaccineName: 'DHPP Booster',
        dateGiven: givenDate,
        nextDueDate: futureDueDate,
        vetId: 'vet_sarah_123',
        branchId: 'branch_central_01',
        notes: 'Lot #DH4482',
        createdAt: givenDate,
      );

      expect(activeVaccine.isUpToDate, isTrue);
      expect(activeVaccine.isOverdue, isFalse);
      expect(activeVaccine.statusBadgeText, 'Up to date');
      expect(activeVaccine.validityDurationText, '1 Year Valid');
    });

    test('overdue vaccination detected correctly at render time', () {
      final now = DateTime.now();
      final givenDate = now.subtract(const Duration(days: 400));
      final pastDueDate = now.subtract(const Duration(days: 35));

      final expiredVaccine = VaccinationModel(
        id: 'vac_002',
        petId: 'pet_milo_001',
        vaccineName: 'Rabies 1-Year',
        dateGiven: givenDate,
        nextDueDate: pastDueDate,
        vetId: 'vet_sarah_123',
        branchId: 'branch_central_01',
        notes: 'Expired tag',
        createdAt: givenDate,
      );

      expect(expiredVaccine.isUpToDate, isFalse);
      expect(expiredVaccine.isOverdue, isTrue);
      expect(expiredVaccine.statusBadgeText, 'Overdue');
    });

    test('due soon badge displayed within 30 days of expiry', () {
      final now = DateTime.now();
      final givenDate = now.subtract(const Duration(days: 345));
      final soonDueDate = now.add(const Duration(days: 20));

      final soonVaccine = VaccinationModel(
        id: 'vac_003',
        petId: 'pet_milo_001',
        vaccineName: 'Bordetella',
        dateGiven: givenDate,
        nextDueDate: soonDueDate,
        vetId: 'vet_sarah_123',
        branchId: 'branch_central_01',
        notes: 'Annual booster',
        createdAt: givenDate,
      );

      expect(soonVaccine.isUpToDate, isTrue);
      expect(soonVaccine.isOverdue, isFalse);
      expect(soonVaccine.statusBadgeText, 'Due Soon');
    });
  });
}
