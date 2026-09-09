import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentModel {
  final String id;
  final String petId;
  final String diagnosis;
  final String medication;
  final String notes;
  final DateTime treatmentDate;
  final DateTime? followUpDate;
  final String status; // 'active' | 'resolved'
  final String vetId;
  final String branchId;
  final DateTime createdAt;

  const TreatmentModel({
    required this.id,
    required this.petId,
    required this.diagnosis,
    required this.medication,
    required this.notes,
    required this.treatmentDate,
    this.followUpDate,
    required this.status,
    required this.vetId,
    required this.branchId,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isResolved => status == 'resolved';
  bool get hasFollowUp => followUpDate != null;

  factory TreatmentModel.fromMap(Map<String, dynamic> map, String id) {
    return TreatmentModel(
      id: id,
      petId: map['petId'] as String? ?? '',
      diagnosis: map['diagnosis'] as String? ?? '',
      medication: map['medication'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      treatmentDate: (map['treatmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      followUpDate: (map['followUpDate'] as Timestamp?)?.toDate(),
      status: map['status'] as String? ?? 'active',
      vetId: map['vetId'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory TreatmentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TreatmentModel.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'diagnosis': diagnosis,
      'medication': medication,
      'notes': notes,
      'treatmentDate': Timestamp.fromDate(treatmentDate),
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'status': status,
      'vetId': vetId,
      'branchId': branchId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TreatmentModel copyWith({
    String? id,
    String? petId,
    String? diagnosis,
    String? medication,
    String? notes,
    DateTime? treatmentDate,
    DateTime? followUpDate,
    String? status,
    String? vetId,
    String? branchId,
    DateTime? createdAt,
  }) {
    return TreatmentModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      diagnosis: diagnosis ?? this.diagnosis,
      medication: medication ?? this.medication,
      notes: notes ?? this.notes,
      treatmentDate: treatmentDate ?? this.treatmentDate,
      followUpDate: followUpDate ?? this.followUpDate,
      status: status ?? this.status,
      vetId: vetId ?? this.vetId,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
