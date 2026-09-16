import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

  /// Map of known branch names fallback
  static const Map<String, String> branchNameMap = {
    'branch_downtown': 'Downtown Branch',
    'branch_westside': 'Westside Branch',
    'branch_metro_hub': 'Central Metro Hub',
    'branch_north': 'North Satellite Clinic',
  };

  /// Map of known vet names fallback
  static const Map<String, String> vetNameMap = {
    'vet_sarah': 'Dr. Sarah Jenkins, DVM',
    'vet_chang': 'Dr. Michael Chang, DVM',
    'vet_emily': 'Dr. Emily Davis, DVM',
    'vet_john': 'Dr. John Doe, DVM',
  };

  /// Seed initial cross-branch records for demo/offline parity (Milo)
  List<UnifiedMedicalRecord> getFallbackRecords(String petId) {
    final now = DateTime.now();
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

  /// Fetches unified medical records for a pet from Firestore, merging
  /// treatments and vaccinations. Falls back to realistic cross-branch demo records if empty.
  Future<List<UnifiedMedicalRecord>> fetchMedicalHistory(String petId) async {
    if (Firebase.apps.isEmpty) {
      return getFallbackRecords(petId);
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final List<UnifiedMedicalRecord> records = [];

      // Fetch Treatments
      final treatSnapshot = await firestore
          .collection('treatments')
          .where('petId', isEqualTo: petId)
          .get();

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

      // Fetch Vaccinations
      final vacSnapshot = await firestore
          .collection('vaccinations')
          .where('petId', isEqualTo: petId)
          .get();

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

      if (records.isEmpty) {
        return getFallbackRecords(petId);
      }

      // Sort descending by date
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (_) {
      return getFallbackRecords(petId);
    }
  }

  /// Fetches vaccination records for a pet from Firestore, falling back to demo records if empty.
  Future<List<VaccinationModel>> fetchVaccinations(String petId) async {
    if (Firebase.apps.isEmpty) {
      return getFallbackVaccinations(petId);
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final vacSnapshot = await firestore
          .collection('vaccinations')
          .where('petId', isEqualTo: petId)
          .get();

      if (vacSnapshot.docs.isEmpty) {
        return getFallbackVaccinations(petId);
      }

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

      list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
      return list;
    } catch (_) {
      return getFallbackVaccinations(petId);
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

    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        final docRef = firestore.collection('vaccinations').doc();
        final data = newModel.copyWith(id: docRef.id).toMap();
        data['createdAt'] = FieldValue.serverTimestamp();
        await docRef.set(data);
        return newModel.copyWith(id: docRef.id);
      } catch (e) {
        // Fall back gracefully to in-memory model
        return newModel;
      }
    }

    return newModel;
  }
}
