import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a clinical consultation or medical treatment record in the VetCare network.
///
/// Treatments follow the patient across clinic branches and provide cross-clinic
/// medical history for veterinarians.
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
  final String? branchName;
  final String? vetName;
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
    this.branchName,
    this.vetName,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isResolved => status == 'resolved';
  bool get hasFollowUp => followUpDate != null;

  /// Helper parser to handle various timestamp formats safely (Timestamp, DateTime, int, or String).
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Construct a [TreatmentModel] from a raw map and document ID.
  factory TreatmentModel.fromMap(Map<String, dynamic> map, String id) {
    return TreatmentModel(
      id: id,
      petId: map['petId'] as String? ?? '',
      diagnosis: map['diagnosis'] as String? ?? '',
      medication: map['medication'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      treatmentDate: _parseDateTime(map['treatmentDate']),
      followUpDate: map['followUpDate'] != null ? _parseDateTime(map['followUpDate']) : null,
      status: map['status'] as String? ?? 'active',
      vetId: map['vetId'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      branchName: map['branchName'] as String?,
      vetName: map['vetName'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Construct a [TreatmentModel] directly from a Firestore [DocumentSnapshot].
  factory TreatmentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TreatmentModel.fromMap(doc.data() ?? {}, doc.id);
  }

  /// Convert to Firestore map representation matching schema specification.
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
      if (branchName != null) 'branchName': branchName,
      if (vetName != null) 'vetName': vetName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with optional overridden fields.
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
    String? branchName,
    String? vetName,
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
      branchName: branchName ?? this.branchName,
      vetName: vetName ?? this.vetName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
