import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationModel {
  final String id;
  final String petId;
  final String vaccineName;
  final DateTime dateGiven;
  final DateTime nextDueDate;
  final String vetId;
  final String branchId;
  final String notes;
  final DateTime createdAt;

  const VaccinationModel({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.dateGiven,
    required this.nextDueDate,
    required this.vetId,
    required this.branchId,
    required this.notes,
    required this.createdAt,
  });

  bool get isUpToDate => nextDueDate.isAfter(DateTime.now());

  factory VaccinationModel.fromMap(Map<String, dynamic> map, String id) {
    return VaccinationModel(
      id: id,
      petId: map['petId'] as String? ?? '',
      vaccineName: map['vaccineName'] as String? ?? '',
      dateGiven: (map['dateGiven'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextDueDate: (map['nextDueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vetId: map['vetId'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory VaccinationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return VaccinationModel.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'vaccineName': vaccineName,
      'dateGiven': Timestamp.fromDate(dateGiven),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'vetId': vetId,
      'branchId': branchId,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  VaccinationModel copyWith({
    String? id,
    String? petId,
    String? vaccineName,
    DateTime? dateGiven,
    DateTime? nextDueDate,
    String? vetId,
    String? branchId,
    String? notes,
    DateTime? createdAt,
  }) {
    return VaccinationModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      vaccineName: vaccineName ?? this.vaccineName,
      dateGiven: dateGiven ?? this.dateGiven,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      vetId: vetId ?? this.vetId,
      branchId: branchId ?? this.branchId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
