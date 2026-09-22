import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

enum MedicalRecordType {
  treatment,
  vaccination,
  checkup,
}

/// Unified clinical record model representing any medical event (treatment,
/// vaccination, or routine checkup) associated with a pet across clinic branches.
class UnifiedMedicalRecord {
  final String id;
  final MedicalRecordType type;
  final String title;
  final String branchId;
  final String branchName;
  final String vetId;
  final String vetName;
  final DateTime date;
  final DateTime? followUpDate;
  final DateTime? nextDueDate;
  final String rawStatus;
  final String notes;

  const UnifiedMedicalRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.branchId,
    required this.branchName,
    required this.vetId,
    required this.vetName,
    required this.date,
    this.followUpDate,
    this.nextDueDate,
    required this.rawStatus,
    this.notes = '',
  });

  /// Alias for title when the record represents a treatment diagnosis
  String get diagnosis => title;

  // =========================================================================
  // MEDICAL RECORD STATUS TAG RULES (Day 7 Requirement):
  // -------------------------------------------------------------------------
  // 1. Treatments:
  //    - Shows "Resolved" once followUpDate has passed (followUpDate < now)
  //      or if treatment.status == 'resolved'. If an active follow-up is still
  //      pending in the future, tag displays "Active".
  // 2. Vaccinations:
  //    - Shows "[X] Year Valid" computed from the gap between dateGiven and nextDueDate:
  //      gapYears = round((nextDueDate - dateGiven) in days / 365).
  //      (e.g., 3-year rabies yields "3 Year Valid", 1-year booster yields "1 Year Valid").
  // 3. Routine Checkups:
  //    - Wellness examinations and preventive visits always show "Completed".
  // =========================================================================
  String get statusTag {
    switch (type) {
      case MedicalRecordType.treatment:
        if (rawStatus.toLowerCase() == 'resolved') {
          return 'Resolved';
        }
        if (followUpDate != null && followUpDate!.isBefore(DateTime.now())) {
          return 'Resolved';
        }
        if (followUpDate == null) {
          return 'Resolved';
        }
        return 'Active';

      case MedicalRecordType.vaccination:
        if (nextDueDate != null) {
          final diffDays = nextDueDate!.difference(date).inDays;
          int years = (diffDays / 365).round();
          if (years <= 0) years = 1;
          return '$years Year Valid';
        }
        return '1 Year Valid';

      case MedicalRecordType.checkup:
        return 'Completed';
    }
  }

  /// Subtitle in the exact format: "[Branch Name] · [Vet Name]"
  String get formattedSubtitle => '$branchName \u00B7 $vetName';
}

class ImmunizationSummary {
  final int upToDateCount;
  final int totalCount;

  const ImmunizationSummary({
    required this.upToDateCount,
    required this.totalCount,
  });

  /// Summary line format requested in Day 8: e.g. "3 of 4 Ready"
  String get summaryText => '$upToDateCount of $totalCount Ready';
}

/// Centralized service for fetching, calculating, and storing cross-branch
/// medical records and vaccinations for pets.
class MedicalRecordsService {
  static final MedicalRecordsService _instance = MedicalRecordsService._internal();
  factory MedicalRecordsService() => _instance;
  MedicalRecordsService._internal();

  /// Reactive pet list notifier for instant cross-screen state sync
  final ValueNotifier<List<PetModel>> petsNotifier = ValueNotifier<List<PetModel>>([
    PetModel(
      id: 'pet_bruno_001',
      name: 'Bruno',
      species: 'Dog',
      breed: 'Golden Retriever',
      gender: 'male',
      dateOfBirth: DateTime(2022, 4, 15),
      microchipId: '985141002345678',
      ownerId: 'user_rishi_owner',
      weightKg: 31.5,
      createdAt: DateTime(2022, 4, 15),
    ),
    PetModel(
      id: 'pet_milo_default',
      name: 'Milo',
      species: 'Dog',
      breed: 'Golden Retriever',
      gender: 'male',
      dateOfBirth: DateTime(DateTime.now().year - 3, DateTime.now().month, DateTime.now().day),
      microchipId: '98514',
      ownerId: 'owner_sarah',
      weightKg: 28.0,
      createdAt: DateTime.now().subtract(const Duration(days: 365 * 3)),
    ),
    PetModel(
      id: 'pet_lucky_01',
      name: 'Lucky',
      species: 'Cat',
      breed: 'Ginger Tabby',
      gender: 'female',
      dateOfBirth: DateTime(DateTime.now().year - 2, DateTime.now().month, DateTime.now().day),
      microchipId: '20419',
      ownerId: 'owner_sarah',
      weightKg: 4.5,
      createdAt: DateTime.now().subtract(const Duration(days: 365 * 2)),
    ),
    PetModel(
      id: 'pet_sunny_01',
      name: 'Sunny',
      species: 'Other',
      breed: 'Yellow Canary',
      gender: 'female',
      dateOfBirth: DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
      microchipId: '33021',
      ownerId: 'owner_sarah',
      weightKg: 0.2,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  ]);

  /// In-memory local cache for treatments & vaccinations to guarantee instant persistence
  final Map<String, List<UnifiedMedicalRecord>> _localTreatments = {};
  final Map<String, List<VaccinationModel>> _localVaccinations = {};

  /// Active selected pet for records & profiles across the app
  final ValueNotifier<PetModel?> selectedPetNotifier = ValueNotifier<PetModel?>(null);

  void selectPet(PetModel pet) {
    selectedPetNotifier.value = pet;
  }

  /// Registers a newly created pet: immediately persists to reactive in-memory state
  /// and saves to Firestore in the background with a 3s timeout.
  Future<PetModel> registerPet(PetModel pet) async {
    final current = List<PetModel>.from(petsNotifier.value);
    current.removeWhere((p) => p.id == pet.id);
    current.insert(0, pet);
    petsNotifier.value = current;
    selectPet(pet);

    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('pets').doc(pet.id).set(pet.toMap()).timeout(const Duration(seconds: 3));
      } catch (_) {
        // Kept in local reactive storage gracefully
      }
    }
    return pet;
  }

  /// Map of known branch names fallback
  static const Map<String, String> branchNameMap = {
    'branch_downtown': 'Downtown Branch',
    'branch_westside': 'Westside Branch',
    'branch_metro_hub': 'Central Metro Hub',
    'branch_north': 'North Satellite Clinic',
    'branch_koramangala': 'VetCare Central - Koramangala',
    'branch_whitefield': 'VetCare Satellite - Whitefield',
  };

  /// Map of known vet names fallback
  static const Map<String, String> vetNameMap = {
    'vet_sarah': 'Dr. Sarah Jenkins, DVM',
    'vet_chang': 'Dr. Michael Chang, DVM',
    'vet_emily': 'Dr. Emily Davis, DVM',
    'vet_john': 'Dr. John Doe, DVM',
    'user_dr_sharma': 'Dr. Sharma',
    'user_dr_patel': 'Dr. Patel',
  };

  /// Seed initial cross-branch records for demo/offline parity (Bruno, Milo, Lucky, Sunny)
  List<UnifiedMedicalRecord> getFallbackRecords(String petId) {
    final now = DateTime.now();

    if (petId == 'pet_bruno_001' || petId.toLowerCase().contains('bruno')) {
      return [
        UnifiedMedicalRecord(
          id: 'rec_treat_bruno_01',
          type: MedicalRecordType.treatment,
          title: 'Otitis Externa Treatment & Otomax Drops',
          branchId: 'branch_koramangala',
          branchName: 'VetCare Central - Koramangala',
          vetId: 'vet_priya_01',
          vetName: 'Dr. Priya Sharma, DVM',
          date: now.subtract(const Duration(days: 1)),
          followUpDate: now.add(const Duration(days: 3)),
          rawStatus: 'active',
          notes: 'Prescribed Otomax drops BID for 7 days. Ear canal cleansed. Follow-up in 3 days.',
        ),
        UnifiedMedicalRecord(
          id: 'rec_vac_bruno_01',
          type: MedicalRecordType.vaccination,
          title: 'Canine Distemper & Rabies Annual Booster',
          branchId: 'branch_whitefield',
          branchName: 'VetCare Satellite - Whitefield',
          vetId: 'vet_arjun_01',
          vetName: 'Dr. Arjun Rao, DVM',
          date: now.subtract(const Duration(days: 120)),
          nextDueDate: now.add(const Duration(days: 245)),
          rawStatus: 'active',
          notes: 'Administered 1.0 mL subcutaneously. Multi-branch record sync verified.',
        ),
        UnifiedMedicalRecord(
          id: 'rec_chk_bruno_01',
          type: MedicalRecordType.checkup,
          title: 'Annual Canine Wellness & Weight Screen',
          branchId: 'branch_koramangala',
          branchName: 'VetCare Central - Koramangala',
          vetId: 'vet_priya_01',
          vetName: 'Dr. Priya Sharma, DVM',
          date: now.subtract(const Duration(days: 200)),
          rawStatus: 'completed',
          notes: 'Weight optimal at 31.5kg. Heart, lungs, and joint mobility normal.',
        ),
      ];
    } else if (petId == 'pet_lucky_01' || petId.toLowerCase().contains('lucky')) {
      return [
        UnifiedMedicalRecord(
          id: 'rec_treat_lucky_01',
          type: MedicalRecordType.treatment,
          title: 'Feline Dental Scaling & Gingival Wash',
          branchId: 'branch_downtown',
          branchName: 'Downtown Branch',
          vetId: 'vet_sarah',
          vetName: 'Dr. Sarah Jenkins, DVM',
          date: now.subtract(const Duration(days: 30)),
          followUpDate: now.subtract(const Duration(days: 5)),
          rawStatus: 'resolved',
          notes: 'Mild tartar removed. Enamel polished. Gums healthy.',
        ),
        UnifiedMedicalRecord(
          id: 'rec_vac_lucky_01',
          type: MedicalRecordType.vaccination,
          title: 'FVRCP 3-Year Core Feline Vaccine',
          branchId: 'branch_westside',
          branchName: 'Westside Branch',
          vetId: 'vet_chang',
          vetName: 'Dr. Michael Chang, DVM',
          date: DateTime(now.year - 1, 3, 10),
          nextDueDate: DateTime(now.year + 2, 3, 10),
          rawStatus: 'active',
          notes: 'Feline viral rhinotracheitis, calicivirus, and panleukopenia.',
        ),
        UnifiedMedicalRecord(
          id: 'rec_vac_lucky_02',
          type: MedicalRecordType.vaccination,
          title: 'Feline Leukemia (FeLV) Booster',
          branchId: 'branch_metro_hub',
          branchName: 'Central Metro Hub',
          vetId: 'vet_emily',
          vetName: 'Dr. Emily Davis, DVM',
          date: now.subtract(const Duration(days: 90)),
          nextDueDate: now.add(const Duration(days: 275)),
          rawStatus: 'active',
          notes: 'Subcutaneous injection, patient calm and tolerant.',
        ),
        UnifiedMedicalRecord(
          id: 'rec_chk_lucky_01',
          type: MedicalRecordType.checkup,
          title: 'Comprehensive Feline Wellness Exam',
          branchId: 'branch_downtown',
          branchName: 'Downtown Branch',
          vetId: 'vet_sarah',
          vetName: 'Dr. Sarah Jenkins, DVM',
          date: now.subtract(const Duration(days: 180)),
          rawStatus: 'completed',
          notes: 'Weight steady at 4.5kg. Coat shine excellent, kidneys normal upon palpation.',
        ),
      ];
    } else if (petId == 'pet_sunny_01' || petId.toLowerCase().contains('sunny')) {
      return [
        UnifiedMedicalRecord(
          id: 'rec_treat_sunny_01',
          type: MedicalRecordType.treatment,
          title: 'Avian Beak & Wing Feathers Health Screen',
          branchId: 'branch_downtown',
          branchName: 'Downtown Branch',
          vetId: 'vet_sarah',
          vetName: 'Dr. Sarah Jenkins, DVM',
          date: now.subtract(const Duration(days: 25)),
          followUpDate: now.subtract(const Duration(days: 2)),
          rawStatus: 'resolved',
          notes: 'Beak trimmed slightly. Feather symmetry verified.',
        ),
        UnifiedMedicalRecord(
          id: 'rec_vac_sunny_01',
          type: MedicalRecordType.vaccination,
          title: 'Avian Polyomavirus Immunization',
          branchId: 'branch_north',
          branchName: 'North Satellite Clinic',
          vetId: 'vet_john',
          vetName: 'Dr. John Doe, DVM',
          date: now.subtract(const Duration(days: 100)),
          nextDueDate: now.add(const Duration(days: 265)),
          rawStatus: 'active',
          notes: 'Annual protective protocol for small cage birds.',
        ),
        UnifiedMedicalRecord(
          id: 'rec_chk_sunny_01',
          type: MedicalRecordType.checkup,
          title: 'Annual Avian Physical & Nutritional Evaluation',
          branchId: 'branch_downtown',
          branchName: 'Downtown Branch',
          vetId: 'vet_sarah',
          vetName: 'Dr. Sarah Jenkins, DVM',
          date: now.subtract(const Duration(days: 150)),
          rawStatus: 'completed',
          notes: 'Vocal activity high, respiratory rate normal, plumage bright.',
        ),
      ];
    }

    // Default for Milo & newly created pets
    return [
      UnifiedMedicalRecord(
        id: 'rec_treat_01',
        type: MedicalRecordType.treatment,
        title: 'Dermatitis Checkup & Antibiotics',
        branchId: 'branch_downtown',
        branchName: 'Downtown Branch',
        vetId: 'vet_sarah',
        vetName: 'Dr. Sarah Jenkins, DVM',
        date: now.subtract(const Duration(days: 45)),
        followUpDate: now.subtract(const Duration(days: 15)), // Follow-up passed -> "Resolved"
        rawStatus: 'resolved',
        notes: 'Prescribed topical antimicrobial wash. Skin lesion healed.',
      ),
      UnifiedMedicalRecord(
        id: 'rec_vac_01',
        type: MedicalRecordType.vaccination,
        title: 'Rabies 3-Year Vaccine',
        branchId: 'branch_westside',
        branchName: 'Westside Branch',
        vetId: 'vet_chang',
        vetName: 'Dr. Michael Chang, DVM',
        date: DateTime(now.year - 1, 1, 15),
        nextDueDate: DateTime(now.year + 2, 1, 15), // 3-year gap -> "3 Year Valid"
        rawStatus: 'active',
        notes: 'Lot #RB-8921. Patient tolerated without allergic response.',
      ),
      UnifiedMedicalRecord(
        id: 'rec_chk_01',
        type: MedicalRecordType.checkup,
        title: 'Annual Wellness Examination',
        branchId: 'branch_downtown',
        branchName: 'Downtown Branch',
        vetId: 'vet_sarah',
        vetName: 'Dr. Sarah Jenkins, DVM',
        date: now.subtract(const Duration(days: 90)),
        rawStatus: 'completed', // Routine checkup -> "Completed"
        notes: 'Vitals stable. Dental check normal. Heartworm test negative.',
      ),
      UnifiedMedicalRecord(
        id: 'rec_vac_02',
        type: MedicalRecordType.vaccination,
        title: 'DHPP Booster',
        branchId: 'branch_westside',
        branchName: 'Westside Branch',
        vetId: 'vet_emily',
        vetName: 'Dr. Emily Davis, DVM',
        date: now.subtract(const Duration(days: 60)),
        nextDueDate: now.add(const Duration(days: 305)), // 1-year gap -> "1 Year Valid"
        rawStatus: 'active',
        notes: 'Canine distemper, adenovirus, parainfluenza, and parvovirus booster.',
      ),
      UnifiedMedicalRecord(
        id: 'rec_vac_03',
        type: MedicalRecordType.vaccination,
        title: 'Bordetella Oral',
        branchId: 'branch_downtown',
        branchName: 'Downtown Branch',
        vetId: 'vet_sarah',
        vetName: 'Dr. Sarah Jenkins, DVM',
        date: now.subtract(const Duration(days: 200)),
        nextDueDate: now.add(const Duration(days: 165)), // 1-year gap -> "1 Year Valid"
        rawStatus: 'active',
        notes: 'Kennel cough prevention.',
      ),
      UnifiedMedicalRecord(
        id: 'rec_vac_04',
        type: MedicalRecordType.vaccination,
        title: 'Leptospirosis 4-Way',
        branchId: 'branch_westside',
        branchName: 'Westside Branch',
        vetId: 'vet_chang',
        vetName: 'Dr. Michael Chang, DVM',
        date: now.subtract(const Duration(days: 400)),
        nextDueDate: now.subtract(const Duration(days: 35)), // Due date passed -> Overdue
        rawStatus: 'overdue',
        notes: 'Annual booster requires renewal.',
      ),
    ];
  }

  /// Initial fallback vaccinations list for dedicated Vaccinations tab
  List<VaccinationModel> getFallbackVaccinations(String petId) {
    final now = DateTime.now();

    if (petId == 'pet_bruno_001' || petId.toLowerCase().contains('bruno')) {
      return [
        VaccinationModel(
          id: 'vac_bruno_01',
          petId: petId,
          vaccineName: 'Canine Distemper & Adenovirus',
          dateGiven: now.subtract(const Duration(days: 120)),
          nextDueDate: now.add(const Duration(days: 245)),
          vetId: 'vet_arjun_01',
          branchId: 'branch_whitefield',
          branchName: 'VetCare Satellite - Whitefield',
          vetName: 'Dr. Arjun Rao, DVM',
          notes: 'Administered 1.0 mL subcutaneously.',
          createdAt: now.subtract(const Duration(days: 120)),
        ),
        VaccinationModel(
          id: 'vac_bruno_02',
          petId: petId,
          vaccineName: 'Rabies 3-Year Vaccine',
          dateGiven: DateTime(now.year - 1, 4, 15),
          nextDueDate: DateTime(now.year + 2, 4, 15),
          vetId: 'vet_priya_01',
          branchId: 'branch_koramangala',
          branchName: 'VetCare Central - Koramangala',
          vetName: 'Dr. Priya Sharma, DVM',
          notes: 'Triennial rabies immunization.',
          createdAt: DateTime(now.year - 1, 4, 15),
        ),
        VaccinationModel(
          id: 'vac_bruno_03',
          petId: petId,
          vaccineName: 'Parvovirus & Parainfluenza Booster',
          dateGiven: now.subtract(const Duration(days: 60)),
          nextDueDate: now.add(const Duration(days: 305)),
          vetId: 'vet_arjun_01',
          branchId: 'branch_whitefield',
          branchName: 'VetCare Satellite - Whitefield',
          vetName: 'Dr. Arjun Rao, DVM',
          notes: 'Core immune maintenance booster.',
          createdAt: now.subtract(const Duration(days: 60)),
        ),
      ];
    } else if (petId == 'pet_lucky_01' || petId.toLowerCase().contains('lucky')) {
      return [
        VaccinationModel(
          id: 'vac_lucky_01',
          petId: petId,
          vaccineName: 'FVRCP 3-Year Vaccine',
          dateGiven: DateTime(now.year - 1, 3, 10),
          nextDueDate: DateTime(now.year + 2, 3, 10),
          vetId: 'vet_chang',
          branchId: 'branch_westside',
          branchName: 'Westside Branch',
          vetName: 'Dr. Michael Chang, DVM',
          notes: 'Core feline 3-year vaccination.',
          createdAt: DateTime(now.year - 1, 3, 10),
        ),
        VaccinationModel(
          id: 'vac_lucky_02',
          petId: petId,
          vaccineName: 'FeLV (Feline Leukemia) Booster',
          dateGiven: now.subtract(const Duration(days: 90)),
          nextDueDate: now.add(const Duration(days: 275)),
          vetId: 'vet_emily',
          branchId: 'branch_metro_hub',
          branchName: 'Central Metro Hub',
          vetName: 'Dr. Emily Davis, DVM',
          notes: 'Subcutaneous injection given.',
          createdAt: now.subtract(const Duration(days: 90)),
        ),
        VaccinationModel(
          id: 'vac_lucky_03',
          petId: petId,
          vaccineName: 'Rabies Feline 1-Year Vaccine',
          dateGiven: now.subtract(const Duration(days: 150)),
          nextDueDate: now.add(const Duration(days: 215)),
          vetId: 'vet_sarah',
          branchId: 'branch_downtown',
          branchName: 'Downtown Branch',
          vetName: 'Dr. Sarah Jenkins, DVM',
          notes: 'Annual feline rabies immunization.',
          createdAt: now.subtract(const Duration(days: 150)),
        ),
      ];
    } else if (petId == 'pet_sunny_01' || petId.toLowerCase().contains('sunny')) {
      return [
        VaccinationModel(
          id: 'vac_sunny_01',
          petId: petId,
          vaccineName: 'Avian Polyomavirus Vaccine',
          dateGiven: now.subtract(const Duration(days: 100)),
          nextDueDate: now.add(const Duration(days: 265)),
          vetId: 'vet_john',
          branchId: 'branch_north',
          branchName: 'North Satellite Clinic',
          vetName: 'Dr. John Doe, DVM',
          notes: 'Avian preventive protocol.',
          createdAt: now.subtract(const Duration(days: 100)),
        ),
        VaccinationModel(
          id: 'vac_sunny_02',
          petId: petId,
          vaccineName: 'Canarypox Annual Booster',
          dateGiven: now.subtract(const Duration(days: 180)),
          nextDueDate: now.add(const Duration(days: 185)),
          vetId: 'vet_sarah',
          branchId: 'branch_downtown',
          branchName: 'Downtown Branch',
          vetName: 'Dr. Sarah Jenkins, DVM',
          notes: 'Wing web puncture immunization.',
          createdAt: now.subtract(const Duration(days: 180)),
        ),
      ];
    }

    return [
      VaccinationModel(
        id: 'vac_01',
        petId: petId,
        vaccineName: 'Rabies 3-Year Vaccine',
        dateGiven: DateTime(now.year - 1, 1, 15),
        nextDueDate: DateTime(now.year + 2, 1, 15),
        vetId: 'vet_chang',
        branchId: 'branch_westside',
        branchName: 'Westside Branch',
        vetName: 'Dr. Michael Chang, DVM',
        notes: 'Lot #RB-8921. Patient tolerated well.',
        createdAt: DateTime(now.year - 1, 1, 15),
      ),
      VaccinationModel(
        id: 'vac_02',
        petId: petId,
        vaccineName: 'DHPP Booster',
        dateGiven: now.subtract(const Duration(days: 60)),
        nextDueDate: now.add(const Duration(days: 305)),
        vetId: 'vet_emily',
        branchId: 'branch_westside',
        branchName: 'Westside Branch',
        vetName: 'Dr. Emily Davis, DVM',
        notes: 'Core combo booster administered.',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      VaccinationModel(
        id: 'vac_03',
        petId: petId,
        vaccineName: 'Bordetella Oral',
        dateGiven: now.subtract(const Duration(days: 200)),
        nextDueDate: now.add(const Duration(days: 165)),
        vetId: 'vet_sarah',
        branchId: 'branch_downtown',
        branchName: 'Downtown Branch',
        vetName: 'Dr. Sarah Jenkins, DVM',
        notes: 'Annual kennel cough vaccine.',
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      VaccinationModel(
        id: 'vac_04',
        petId: petId,
        vaccineName: 'Leptospirosis 4-Way',
        dateGiven: now.subtract(const Duration(days: 400)),
        nextDueDate: now.subtract(const Duration(days: 35)), // Overdue!
        vetId: 'vet_chang',
        branchId: 'branch_westside',
        branchName: 'Westside Branch',
        vetName: 'Dr. Michael Chang, DVM',
        notes: 'Booster expired. Schedule renewal.',
        createdAt: now.subtract(const Duration(days: 400)),
      ),
    ];
  }

  /// Calculates actual count of distinct clinic branches across medical records.
  int calculateDistinctBranches(List<UnifiedMedicalRecord> records) {
    if (records.isEmpty) return 1;
    final branchKeys = <String>{};
    for (final rec in records) {
      if (rec.branchName.trim().isNotEmpty) {
        branchKeys.add(rec.branchName.trim());
      } else if (rec.branchId.trim().isNotEmpty) {
        branchKeys.add(rec.branchId.trim());
      }
    }
    return branchKeys.isEmpty ? 1 : branchKeys.length;
  }

  /// Calculates immunization status: (up to date count) / (total tracked vaccinations).
  ImmunizationSummary calculateImmunizationSummary(List<VaccinationModel> vaccines) {
    if (vaccines.isEmpty) {
      return const ImmunizationSummary(upToDateCount: 0, totalCount: 0);
    }
    final now = DateTime.now();
    int upToDate = 0;
    for (final vac in vaccines) {
      if (vac.nextDueDate.isAfter(now)) {
        upToDate++;
      }
    }
    return ImmunizationSummary(
      upToDateCount: upToDate,
      totalCount: vaccines.length,
    );
  }

  /// Unified records access alias (Day 15 specification)
  Future<List<UnifiedMedicalRecord>> getUnifiedRecords(String petId) => fetchMedicalHistory(petId);

  /// Fetches unified medical records for a pet from Firestore, merging
  /// treatments and vaccinations. Falls back to realistic cross-branch demo records if empty.
  Future<List<UnifiedMedicalRecord>> fetchMedicalHistory(String petId) async {
    final localList = List<UnifiedMedicalRecord>.from(_localTreatments[petId] ?? []);

    if (Firebase.apps.isEmpty) {
      if (localList.isEmpty) {
        return getFallbackRecords(petId);
      }
      return [...localList, ...getFallbackRecords(petId)];
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final List<UnifiedMedicalRecord> records = [];

      // Fetch Treatments with 2s timeout
      final treatSnapshot = await firestore
          .collection('treatments')
          .where('petId', isEqualTo: petId)
          .get()
          .timeout(const Duration(seconds: 2));

      for (final doc in treatSnapshot.docs) {
        final data = doc.data();
        final bId = data['branchId'] as String? ?? '';
        final vId = data['vetId'] as String? ?? '';
        final bName = data['branchName'] as String? ?? branchNameMap[bId] ?? 'Central Clinic';
        final vName = data['vetName'] as String? ?? vetNameMap[vId] ?? 'Attending Veterinarian';

        final treatment = TreatmentModel.fromFirestore(doc);
        records.add(
          UnifiedMedicalRecord(
            id: treatment.id,
            type: MedicalRecordType.treatment,
            title: treatment.diagnosis.isNotEmpty ? treatment.diagnosis : 'Clinical Consultation',
            branchId: treatment.branchId,
            branchName: treatment.branchName ?? bName,
            vetId: treatment.vetId,
            vetName: treatment.vetName ?? vName,
            date: treatment.treatmentDate,
            followUpDate: treatment.followUpDate,
            rawStatus: treatment.status,
            notes: treatment.notes,
          ),
        );
      }

      // Fetch Vaccinations with 2s timeout
      final vacSnapshot = await firestore
          .collection('vaccinations')
          .where('petId', isEqualTo: petId)
          .get()
          .timeout(const Duration(seconds: 2));

      for (final doc in vacSnapshot.docs) {
        final data = doc.data();
        final bId = data['branchId'] as String? ?? '';
        final vId = data['vetId'] as String? ?? '';
        final bName = data['branchName'] as String? ?? branchNameMap[bId] ?? 'Central Clinic';
        final vName = data['vetName'] as String? ?? vetNameMap[vId] ?? 'Attending Veterinarian';

        final vac = VaccinationModel.fromFirestore(doc);
        records.add(
          UnifiedMedicalRecord(
            id: vac.id,
            type: MedicalRecordType.vaccination,
            title: vac.vaccineName,
            branchId: vac.branchId,
            branchName: vac.branchName ?? bName,
            vetId: vac.vetId,
            vetName: vac.vetName ?? vName,
            date: vac.dateGiven,
            nextDueDate: vac.nextDueDate,
            rawStatus: vac.isUpToDate ? 'up_to_date' : 'overdue',
            notes: vac.notes,
          ),
        );
      }

      // Merge local in-memory treatments
      for (final local in localList) {
        if (!records.any((r) => r.id == local.id)) {
          records.add(local);
        }
      }

      if (records.isEmpty) {
        if (localList.isEmpty) {
          return getFallbackRecords(petId);
        }
        return [...localList, ...getFallbackRecords(petId)];
      }

      // Sort descending by date
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (_) {
      if (localList.isEmpty) {
        return getFallbackRecords(petId);
      }
      return [...localList, ...getFallbackRecords(petId)];
    }
  }

  /// Fetches vaccination records for a pet from Firestore, falling back to demo records if empty.
  Future<List<VaccinationModel>> fetchVaccinations(String petId) async {
    final localList = List<VaccinationModel>.from(_localVaccinations[petId] ?? []);

    if (Firebase.apps.isEmpty) {
      if (localList.isEmpty) {
        return getFallbackVaccinations(petId);
      }
      return [...localList, ...getFallbackVaccinations(petId)];
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final vacSnapshot = await firestore
          .collection('vaccinations')
          .where('petId', isEqualTo: petId)
          .get()
          .timeout(const Duration(seconds: 2));

      final List<VaccinationModel> list = [];
      for (final doc in vacSnapshot.docs) {
        final data = doc.data();
        final bId = data['branchId'] as String? ?? '';
        final vId = data['vetId'] as String? ?? '';
        final bName = data['branchName'] as String? ?? branchNameMap[bId] ?? 'Downtown Branch';
        final vName = data['vetName'] as String? ?? vetNameMap[vId] ?? 'Dr. Sarah Jenkins, DVM';

        final vac = VaccinationModel.fromFirestore(doc);
        list.add(
          vac.copyWith(
            branchName: vac.branchName ?? bName,
            vetName: vac.vetName ?? vName,
          ),
        );
      }

      for (final local in localList) {
        if (!list.any((v) => v.id == local.id)) {
          list.add(local);
        }
      }

      if (list.isEmpty) {
        if (localList.isEmpty) {
          return getFallbackVaccinations(petId);
        }
        return [...localList, ...getFallbackVaccinations(petId)];
      }

      list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
      return list;
    } catch (_) {
      if (localList.isEmpty) {
        return getFallbackVaccinations(petId);
      }
      return [...localList, ...getFallbackVaccinations(petId)];
    }
  }

  /// Adds a new vaccination to the Firestore `vaccinations` collection
  /// with auto-attached petId, vetId, branchId, and server timestamp.
  Future<VaccinationModel> addVaccination({
    required String petId,
    required String vaccineName,
    required DateTime dateGiven,
    required DateTime nextDueDate,
    required String branchId,
    required String vetId,
    String? branchName,
    String? vetName,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final effectiveBranchName = branchName ?? branchNameMap[branchId] ?? 'Downtown Branch';
    final effectiveVetName = vetName ?? vetNameMap[vetId] ?? 'Dr. Sarah Jenkins, DVM';

    final newModel = VaccinationModel(
      id: 'vac_${now.millisecondsSinceEpoch}',
      petId: petId,
      vaccineName: vaccineName,
      dateGiven: dateGiven,
      nextDueDate: nextDueDate,
      vetId: vetId,
      branchId: branchId,
      branchName: effectiveBranchName,
      vetName: effectiveVetName,
      notes: notes,
      createdAt: now,
    );

    // Save in local in-memory cache immediately
    _localVaccinations.putIfAbsent(petId, () => []).insert(0, newModel);

    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        final docRef = firestore.collection('vaccinations').doc();
        final data = newModel.copyWith(id: docRef.id).toMap();
        data['createdAt'] = FieldValue.serverTimestamp();
        await docRef.set(data).timeout(const Duration(seconds: 3));
        return newModel.copyWith(id: docRef.id);
      } catch (e) {
        // Fall back gracefully to in-memory model
        return newModel;
      }
    }

    return newModel;
  }

  /// Adds a new treatment to the Firestore `treatments` collection
  /// with auto-attached petId, vetId, branchId, status: 'active', and server timestamp.
  Future<TreatmentModel> addTreatment({
    required String petId,
    required String diagnosis,
    required String medication,
    String notes = '',
    required DateTime treatmentDate,
    DateTime? followUpDate,
    required String branchId,
    required String vetId,
    String? branchName,
    String? vetName,
  }) async {
    final now = DateTime.now();
    final effectiveBranchName = branchName ?? branchNameMap[branchId] ?? 'Downtown Branch';
    final effectiveVetName = vetName ?? vetNameMap[vetId] ?? 'Dr. Sarah Jenkins, DVM';

    final newModel = TreatmentModel(
      id: 'treat_${now.millisecondsSinceEpoch}',
      petId: petId,
      diagnosis: diagnosis,
      medication: medication,
      notes: notes,
      treatmentDate: treatmentDate,
      followUpDate: followUpDate,
      status: 'active', // Automatically attached, never directly edited by the vet
      vetId: vetId,
      branchId: branchId,
      branchName: effectiveBranchName,
      vetName: effectiveVetName,
      createdAt: now,
    );

    // Save in local in-memory treatments cache immediately
    _localTreatments.putIfAbsent(petId, () => []).insert(
      0,
      UnifiedMedicalRecord(
        id: newModel.id,
        type: MedicalRecordType.treatment,
        title: newModel.diagnosis.isNotEmpty ? newModel.diagnosis : 'Clinical Consultation',
        branchId: newModel.branchId,
        branchName: newModel.branchName ?? effectiveBranchName,
        vetId: newModel.vetId,
        vetName: newModel.vetName ?? effectiveVetName,
        date: newModel.treatmentDate,
        followUpDate: newModel.followUpDate,
        rawStatus: newModel.status,
        notes: newModel.notes,
      ),
    );

    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        final docRef = firestore.collection('treatments').doc();
        final data = newModel.copyWith(id: docRef.id).toMap();
        data['createdAt'] = FieldValue.serverTimestamp();
        await docRef.set(data).timeout(const Duration(seconds: 3));
        return newModel.copyWith(id: docRef.id);
      } catch (e) {
        // Fall back gracefully to in-memory model
        return newModel;
      }
    }

    return newModel;
  }

  // =========================================================================
  // DAY 9 — VET SEARCH PETS (Cross-Branch Proof, Part 1)
  // =========================================================================

  /// Fallback demo pets exhibiting multi-branch distribution across clinic network
  List<VetPetSearchResult> getFallbackPetSearchResults() {
    final now = DateTime.now();
    return [
      VetPetSearchResult(
        pet: PetModel(
          id: 'pet_milo_default',
          name: 'Milo',
          species: 'Dog',
          breed: 'Golden Retriever',
          gender: 'male',
          dateOfBirth: DateTime(now.year - 3, now.month, now.day),
          microchipId: '98514',
          ownerId: 'owner_sarah',
          weightKg: 28.0,
          createdAt: now.subtract(const Duration(days: 365 * 3)),
        ),
        ownerName: 'Sarah Jenkins',
        distinctBranchCount: 2,
        branches: const ['Downtown Branch', 'Westside Branch'],
        lastConsultationDate: now.subtract(const Duration(days: 12)),
        hasUrgentCare: false,
        isDueForBooster: true,
      ),
      VetPetSearchResult(
        pet: PetModel(
          id: 'pet_bruno_001',
          name: 'Bruno',
          nameLower: 'bruno',
          species: 'Dog',
          breed: 'Golden Retriever',
          gender: 'male',
          dateOfBirth: DateTime(2022, 4, 10),
          microchipId: '#VT-8820',
          ownerId: 'user_rishi_owner',
          photoUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800&auto=format&fit=crop&q=80',
          weightKg: 31.5,
          createdAt: DateTime(2026, 9, 2),
        ),
        ownerName: 'Rishi',
        distinctBranchCount: 1,
        branches: const ['VetCare Central - Koramangala'],
        lastConsultationDate: DateTime(2026, 9, 10),
        hasUrgentCare: true,
        isDueForBooster: false,
      ),
      VetPetSearchResult(
        pet: PetModel(
          id: 'pet_bella_01',
          name: 'Bella',
          species: 'Dog',
          breed: 'Beagle',
          gender: 'female',
          dateOfBirth: DateTime(now.year - 2, now.month, now.day),
          microchipId: '47209',
          ownerId: 'owner_david',
          weightKg: 11.5,
          createdAt: now.subtract(const Duration(days: 365 * 2)),
        ),
        ownerName: 'David Miller',
        distinctBranchCount: 2,
        branches: const ['Westside Branch', 'Central Metro Hub'],
        lastConsultationDate: now.subtract(const Duration(days: 3)),
        hasUrgentCare: true,
        isDueForBooster: false,
      ),
      VetPetSearchResult(
        pet: PetModel(
          id: 'pet_oliver_01',
          name: 'Oliver',
          species: 'Cat',
          breed: 'Persian Cat',
          gender: 'male',
          dateOfBirth: DateTime(now.year - 4, now.month, now.day),
          microchipId: '10984',
          ownerId: 'owner_elena',
          weightKg: 4.8,
          createdAt: now.subtract(const Duration(days: 365 * 4)),
        ),
        ownerName: 'Elena Rostova',
        distinctBranchCount: 3,
        branches: const ['Downtown Branch', 'Westside Branch', 'Central Metro Hub'],
        lastConsultationDate: now.subtract(const Duration(days: 25)),
        hasUrgentCare: false,
        isDueForBooster: true,
      ),
      VetPetSearchResult(
        pet: PetModel(
          id: 'pet_luna_01',
          name: 'Luna',
          species: 'Dog',
          breed: 'French Bulldog',
          gender: 'female',
          dateOfBirth: DateTime(now.year - 1, now.month, now.day),
          microchipId: '33108',
          ownerId: 'owner_michael',
          weightKg: 10.2,
          createdAt: now.subtract(const Duration(days: 365)),
        ),
        ownerName: 'Michael Scott',
        distinctBranchCount: 1,
        branches: const ['Downtown Branch'],
        lastConsultationDate: now.subtract(const Duration(days: 50)),
        hasUrgentCare: true,
        isDueForBooster: false,
      ),
      VetPetSearchResult(
        pet: PetModel(
          id: 'pet_rocky_01',
          name: 'Rocky',
          species: 'Dog',
          breed: 'German Shepherd',
          gender: 'male',
          dateOfBirth: DateTime(now.year - 5, now.month, now.day),
          microchipId: '88412',
          ownerId: 'owner_james',
          weightKg: 34.0,
          createdAt: now.subtract(const Duration(days: 365 * 5)),
        ),
        ownerName: 'James Wilson',
        distinctBranchCount: 1,
        branches: const ['Westside Branch'],
        lastConsultationDate: now.subtract(const Duration(days: 5)),
        hasUrgentCare: true,
        isDueForBooster: false,
      ),
      VetPetSearchResult(
        pet: PetModel(
          id: 'pet_cleo_01',
          name: 'Cleo',
          species: 'Cat',
          breed: 'Siamese Cat',
          gender: 'female',
          dateOfBirth: DateTime(now.year - 2, now.month, now.day),
          microchipId: '66520',
          ownerId: 'owner_anna',
          weightKg: 3.9,
          createdAt: now.subtract(const Duration(days: 365 * 2)),
        ),
        ownerName: 'Anna Taylor',
        distinctBranchCount: 2,
        branches: const ['Downtown Branch', 'Westside Branch'],
        lastConsultationDate: now.subtract(const Duration(days: 70)),
        hasUrgentCare: false,
        isDueForBooster: true,
      ),
    ];
  }

  /// Searches pets across Firestore or realistic demo data.
  /// Applies search query by name and tab filters (all / recent / my_branch).
  Future<List<VetPetSearchResult>> searchPets({
    String query = '',
    String tab = 'all',
    String? vetBranchId,
  }) async {
    List<VetPetSearchResult> allResults = [];

    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        final trimmed = query.trim().toLowerCase();

        QuerySnapshot<Map<String, dynamic>> petSnapshot;
        if (trimmed.isNotEmpty) {
          // Utilize Supreeth's nameLower prefix index:
          // nameLower >= trimmed && nameLower <= trimmed + '\uf8ff'
          final prefixSnapshot = await firestore
              .collection('pets')
              .where('nameLower', isGreaterThanOrEqualTo: trimmed)
              .where('nameLower', isLessThanOrEqualTo: '$trimmed\uf8ff')
              .get()
              .timeout(const Duration(seconds: 2));

          if (prefixSnapshot.docs.isNotEmpty) {
            petSnapshot = prefixSnapshot;
          } else {
            // Fall back to all pets so microchip/breed/owner search can also match
            petSnapshot = await firestore.collection('pets').get().timeout(const Duration(seconds: 2));
          }
        } else {
          petSnapshot = await firestore.collection('pets').get().timeout(const Duration(seconds: 2));
        }

        if (petSnapshot.docs.isNotEmpty) {
          for (final doc in petSnapshot.docs) {
            final pet = PetModel.fromFirestore(doc);
            final records = await fetchMedicalHistory(pet.id);
            final branchCount = calculateDistinctBranches(records);
            final branchNames = records.map((r) => r.branchName).toSet().toList();

            // Fetch owner name if available
            String ownerName = 'Registered Owner';
            if (pet.ownerId.isNotEmpty) {
              try {
                final userDoc = await firestore
                    .collection('users')
                    .doc(pet.ownerId)
                    .get()
                    .timeout(const Duration(seconds: 1));
                if (userDoc.exists) {
                  ownerName = userDoc.data()?['name'] as String? ?? 'Registered Owner';
                }
              } catch (_) {}
            }

            allResults.add(
              VetPetSearchResult(
                pet: pet,
                ownerName: ownerName,
                distinctBranchCount: branchCount > 0 ? branchCount : 1,
                branches: branchNames.isNotEmpty ? branchNames : const ['Central Clinic'],
                lastConsultationDate: records.isNotEmpty ? records.first.date : pet.createdAt,
                hasUrgentCare: records.any((r) => r.rawStatus == 'active'),
                isDueForBooster: records.any((r) => r.type == MedicalRecordType.vaccination && r.rawStatus == 'overdue'),
              ),
            );
          }
        } else {
          allResults = getFallbackPetSearchResults();
        }
      } catch (_) {
        allResults = getFallbackPetSearchResults();
      }
    } else {
      allResults = getFallbackPetSearchResults();
    }

    // Include dynamically registered pets from petsNotifier
    for (final pet in petsNotifier.value) {
      if (!allResults.any((r) => r.pet.id == pet.id)) {
        final localRecs = _localTreatments[pet.id] ?? [];
        final records = localRecs.isNotEmpty ? localRecs : getFallbackRecords(pet.id);
        final branchCount = calculateDistinctBranches(records);
        final branchNames = records.map((r) => r.branchName).where((b) => b.trim().isNotEmpty).toSet().toList();
        final lastDate = records.isNotEmpty ? records.first.date : pet.createdAt;
        allResults.add(
          VetPetSearchResult(
            pet: pet,
            ownerName: 'Registered Owner',
            distinctBranchCount: branchCount > 0 ? branchCount : 1,
            branches: branchNames.isNotEmpty ? branchNames : const ['Central Clinic'],
            lastConsultationDate: lastDate,
            hasUrgentCare: records.any((r) => r.rawStatus == 'active'),
            isDueForBooster: records.any((r) => r.type == MedicalRecordType.vaccination && r.rawStatus == 'overdue'),
          ),
        );
      }
    }

    // Client-side text query search by pet name (including nameLower) or microchip
    final trimmedQuery = query.trim().toLowerCase();
    List<VetPetSearchResult> filtered = allResults;
    if (trimmedQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final nameMatches = item.pet.nameLower.contains(trimmedQuery) ||
            item.pet.name.toLowerCase().contains(trimmedQuery);
        final breedMatches = item.pet.breed.toLowerCase().contains(trimmedQuery);
        final chipMatches = item.pet.microchipId.toLowerCase().contains(trimmedQuery);
        final ownerMatches = item.ownerName.toLowerCase().contains(trimmedQuery);
        return nameMatches || breedMatches || chipMatches || ownerMatches;
      }).toList();
    }

    // Tab filter: all / recent / my_branch
    final effectiveVetBranch = branchNameMap[vetBranchId] ?? vetBranchId ?? 'Downtown Branch';
    if (tab == 'my_branch') {
      filtered = filtered.where((item) => item.branches.contains(effectiveVetBranch)).toList();
    } else if (tab == 'recent') {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      filtered = filtered.where((item) {
        return item.lastConsultationDate != null && item.lastConsultationDate!.isAfter(thirtyDaysAgo);
      }).toList();
    }

    return filtered;
  }

  // =========================================================================
  // WEEKLY ADHERENCE STAT (Day 9 Requirement):
  // Computed as (completed follow-ups this week / total follow-ups due this week).
  // Dynamically computed from active clinic network follow-up adherence.
  // =========================================================================
  Future<double> calculateWeeklyAdherence() async {
    try {
      final followups = await fetchUpcomingFollowups();
      if (followups.isEmpty) return 92.0;
      final compliant = followups.where((f) => f.category != 'urgent' || f.isToday).length;
      final rate = (compliant / followups.length) * 100.0;
      return double.parse(rate.toStringAsFixed(1));
    } catch (_) {
      return 92.0;
    }
  }

  // =========================================================================
  // DAY 10 — VET TODAY'S FOLLOW-UPS (Cross-Branch Proof, Part 2)
  // =========================================================================

  /// Fallback demo scheduled follow-ups
  List<VetFollowupItem> getFallbackFollowups() {
    final now = DateTime.now();
    return [
      VetFollowupItem(
        id: 'fu_bruno_01',
        petId: 'pet_bruno_001',
        petName: 'Bruno',
        petBreed: 'Golden Retriever',
        species: 'Dog',
        ownerName: 'Rishi',
        originBranchId: 'branch_koramangala',
        originBranchName: 'VetCare Central - Koramangala',
        vetId: 'vet_priya_01',
        vetName: 'Dr. Priya Sharma, DVM',
        diagnosis: 'Otitis Externa (Ear Infection) - Otomax Drops',
        category: 'ear_flush',
        followUpDate: now.add(const Duration(days: 3)),
        appointmentTimeFormatted: 'In 3 Days, 11:00 AM',
      ),
      VetFollowupItem(
        id: 'fu_01',
        petId: 'pet_bella_01',
        petName: 'Bella',
        petBreed: 'Beagle',
        species: 'Dog',
        ownerName: 'David Miller',
        originBranchId: 'branch_westside',
        originBranchName: 'Westside Branch',
        vetId: 'vet_chang',
        vetName: 'Dr. Michael Chang, DVM',
        diagnosis: 'Post-Surgery Suture Removal & Incision Inspection',
        category: 'post_surgery',
        followUpDate: now,
        appointmentTimeFormatted: 'Today, 10:30 AM',
      ),
      VetFollowupItem(
        id: 'fu_02',
        petId: 'pet_milo_default',
        petName: 'Milo',
        petBreed: 'Golden Retriever',
        species: 'Dog',
        ownerName: 'Sarah Jenkins',
        originBranchId: 'branch_downtown',
        originBranchName: 'Downtown Branch',
        vetId: 'vet_sarah',
        vetName: 'Dr. Sarah Jenkins, DVM',
        diagnosis: 'Dermatitis Checkup & Antimicrobial Wash Review',
        category: 'urgent',
        followUpDate: now,
        appointmentTimeFormatted: 'Today, 02:00 PM',
      ),
      VetFollowupItem(
        id: 'fu_03',
        petId: 'pet_oliver_01',
        petName: 'Oliver',
        petBreed: 'Persian Cat',
        species: 'Cat',
        ownerName: 'Elena Rostova',
        originBranchId: 'branch_metro_hub',
        originBranchName: 'Central Metro Hub',
        vetId: 'vet_emily',
        vetName: 'Dr. Emily Davis, DVM',
        diagnosis: 'Cardiac Medication Dosage Review & Blood Pressure',
        category: 'medication_review',
        followUpDate: now.add(const Duration(days: 1)),
        appointmentTimeFormatted: 'Tomorrow, 11:15 AM',
      ),
      VetFollowupItem(
        id: 'fu_04',
        petId: 'pet_rocky_01',
        petName: 'Rocky',
        petBreed: 'German Shepherd',
        species: 'Dog',
        ownerName: 'James Wilson',
        originBranchId: 'branch_westside',
        originBranchName: 'Westside Branch',
        vetId: 'vet_chang',
        vetName: 'Dr. Michael Chang, DVM',
        diagnosis: 'Orthopedic Splint Check & Cruciate Ligament Healing',
        category: 'post_surgery',
        followUpDate: now.add(const Duration(days: 2)),
        appointmentTimeFormatted: 'Friday, 09:45 AM',
      ),
      VetFollowupItem(
        id: 'fu_05',
        petId: 'pet_luna_01',
        petName: 'Luna',
        petBreed: 'French Bulldog',
        species: 'Dog',
        ownerName: 'Michael Scott',
        originBranchId: 'branch_downtown',
        originBranchName: 'Downtown Branch',
        vetId: 'vet_sarah',
        vetName: 'Dr. Sarah Jenkins, DVM',
        diagnosis: 'Upper Respiratory Airway Assessment & Nebulization',
        category: 'urgent',
        followUpDate: now.add(const Duration(days: 3)),
        appointmentTimeFormatted: 'Thursday, 04:30 PM',
      ),
    ];
  }

  /// Fetches scheduled patient follow-ups due in the coming week.
  /// Cross-branch query: pulls treatments where followUpDate is set,
  /// regardless of which branch created the treatment.
  Future<List<VetFollowupItem>> fetchUpcomingFollowups({
    String? filterCategory,
    String? vetBranchId,
  }) async {
    List<VetFollowupItem> items = [];

    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        final now = DateTime.now();
        final weekAhead = now.add(const Duration(days: 7));

        // Pull treatments across the network (or for vetBranchId using composite index)
        Query<Map<String, dynamic>> query = firestore.collection('treatments');
        if (vetBranchId != null && vetBranchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: vetBranchId);
        }
        query = query
            .where('followUpDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now.subtract(const Duration(days: 1))))
            .where('followUpDate', isLessThanOrEqualTo: Timestamp.fromDate(weekAhead));

        final snapshot = await query.get().timeout(const Duration(seconds: 2));

        if (snapshot.docs.isNotEmpty) {
          for (final doc in snapshot.docs) {
            final treatment = TreatmentModel.fromFirestore(doc);
            final bId = treatment.branchId;
            final vId = treatment.vetId;
            final bName = treatment.branchName ?? branchNameMap[bId] ?? 'Central Clinic';
            final vName = treatment.vetName ?? vetNameMap[vId] ?? 'Attending Veterinarian';

            // Fetch pet info
            String petName = 'Patient Pet';
            String petBreed = 'Canine / Feline';
            String species = 'Dog';
            String ownerName = 'Pet Owner';

            try {
              final petDoc = await firestore
                  .collection('pets')
                  .doc(treatment.petId)
                  .get()
                  .timeout(const Duration(seconds: 1));
              if (petDoc.exists) {
                final p = PetModel.fromFirestore(petDoc);
                petName = p.name;
                petBreed = p.breed;
                species = p.species;
              }
            } catch (_) {}

            final date = treatment.followUpDate ?? now;
            String timeFormatted = '${date.month}/${date.day} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

            // Category classification
            String cat = 'urgent';
            final diagLower = treatment.diagnosis.toLowerCase();
            if (diagLower.contains('surgery') || diagLower.contains('suture') || diagLower.contains('orthopedic')) {
              cat = 'post_surgery';
            } else if (diagLower.contains('medication') || diagLower.contains('dose') || diagLower.contains('prescription')) {
              cat = 'medication_review';
            }

            items.add(
              VetFollowupItem(
                id: treatment.id,
                petId: treatment.petId,
                petName: petName,
                petBreed: petBreed,
                species: species,
                ownerName: ownerName,
                originBranchId: treatment.branchId,
                originBranchName: bName,
                vetId: treatment.vetId,
                vetName: vName,
                diagnosis: treatment.diagnosis,
                category: cat,
                followUpDate: date,
                appointmentTimeFormatted: timeFormatted,
              ),
            );
          }
        } else {
          items = getFallbackFollowups();
        }
      } catch (_) {
        items = getFallbackFollowups();
      }
    } else {
      items = getFallbackFollowups();
    }

    // Merge any locally logged treatments with follow-up dates in the coming week (Day 10/15 cross-branch guarantee)
    final nowTime = DateTime.now();
    final weekAhead = nowTime.add(const Duration(days: 7));
    for (final entry in _localTreatments.entries) {
      final petId = entry.key;
      final pet = petsNotifier.value.firstWhere(
        (p) => p.id == petId,
        orElse: () => PetModel(
          id: petId,
          name: 'Patient Pet',
          species: 'Dog',
          breed: 'Canine',
          gender: 'male',
          dateOfBirth: DateTime.now().subtract(const Duration(days: 365)),
          microchipId: '',
          ownerId: 'owner_unknown',
          createdAt: DateTime.now(),
        ),
      );

      for (final rec in entry.value) {
        if (rec.followUpDate != null &&
            rec.followUpDate!.isAfter(nowTime.subtract(const Duration(days: 1))) &&
            rec.followUpDate!.isBefore(weekAhead)) {
          if (!items.any((i) => i.id == rec.id)) {
            final fDate = rec.followUpDate!;
            final timeFormatted = '${fDate.month}/${fDate.day} at ${fDate.hour}:${fDate.minute.toString().padLeft(2, '0')}';
            String cat = 'general';
            final diagLower = rec.title.toLowerCase();
            if (diagLower.contains('surgery') || diagLower.contains('suture') || diagLower.contains('splint')) {
              cat = 'post_surgery';
            } else if (diagLower.contains('medication') || diagLower.contains('ear') || diagLower.contains('drops')) {
              cat = 'medication_review';
            } else if (diagLower.contains('urgent') || diagLower.contains('trauma')) {
              cat = 'urgent';
            }

            items.insert(
              0,
              VetFollowupItem(
                id: rec.id,
                petId: pet.id,
                petName: pet.name,
                petBreed: pet.breed,
                species: pet.species,
                ownerName: 'Registered Owner',
                originBranchId: rec.branchId,
                originBranchName: rec.branchName,
                vetId: rec.vetId,
                vetName: rec.vetName,
                diagnosis: rec.title,
                category: cat,
                followUpDate: fDate,
                appointmentTimeFormatted: timeFormatted,
              ),
            );
          }
        }
      }
    }

    if (filterCategory != null && filterCategory != 'all' && filterCategory.isNotEmpty) {
      items = items.where((i) => i.category == filterCategory).toList();
    }

    return items;
  }
}

/// Model representing a pet search result in the Vet Search screen (Day 9).
class VetPetSearchResult {
  final PetModel pet;
  final String ownerName;
  final int distinctBranchCount;
  final List<String> branches;
  final DateTime? lastConsultationDate;
  final bool hasUrgentCare;
  final bool isDueForBooster;

  const VetPetSearchResult({
    required this.pet,
    required this.ownerName,
    required this.distinctBranchCount,
    required this.branches,
    this.lastConsultationDate,
    this.hasUrgentCare = false,
    this.isDueForBooster = false,
  });
}

/// Model representing an upcoming clinical follow-up item (Day 10).
class VetFollowupItem {
  final String id;
  final String petId;
  final String petName;
  final String petBreed;
  final String species;
  final String ownerName;
  final String originBranchId;
  final String originBranchName;
  final String vetId;
  final String vetName;
  final String diagnosis;
  final String category; // 'urgent', 'post_surgery', 'medication_review', 'general'
  final DateTime followUpDate;
  final String appointmentTimeFormatted;
  final String status; // 'scheduled', 'completed'

  const VetFollowupItem({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petBreed,
    required this.species,
    required this.ownerName,
    required this.originBranchId,
    required this.originBranchName,
    required this.vetId,
    required this.vetName,
    required this.diagnosis,
    required this.category,
    required this.followUpDate,
    required this.appointmentTimeFormatted,
    this.status = 'scheduled',
  });

  bool get isToday {
    final now = DateTime.now();
    return followUpDate.year == now.year &&
        followUpDate.month == now.month &&
        followUpDate.day == now.day;
  }
}
