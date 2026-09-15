import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an immunization or vaccination record for a patient pet.
///
/// Status (Up to date / Overdue / X Year Valid) is computed dynamically client-side
/// at render time to prevent silent data staleness in the database.
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

  /// True if current time has not exceeded the expiration due date.
  bool get isUpToDate => nextDueDate.isAfter(DateTime.now());

  /// True if expiration due date has passed.
  bool get isOverdue => nextDueDate.isBefore(DateTime.now());

  /// Number of days remaining until due date (negative if overdue).
  int get daysUntilDue => nextDueDate.difference(DateTime.now()).inDays;

  /// Human-readable validity label for the UI badge (e.g. "Up to date", "Due soon", "Overdue").
  String get statusBadgeText {
    final now = DateTime.now();
    if (nextDueDate.isBefore(now)) {
      return 'Overdue';
    }
    final daysRemaining = nextDueDate.difference(now).inDays;
    if (daysRemaining <= 30) {
      return 'Due Soon';
    }
    return 'Up to date';
  }

  /// Human-readable validity interval based on dateGiven and nextDueDate (e.g. "3 Year Valid", "1 Year Valid").
  String get validityDurationText {
    final diffDays = nextDueDate.difference(dateGiven).inDays;
    final years = (diffDays / 365).round();
    if (years >= 1) {
      return '$years Year Valid';
    }
    final months = (diffDays / 30).round();
    return '$months Month Valid';
  }

  /// Helper parser to handle various timestamp formats safely (Timestamp, DateTime, int, or String).
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Construct a [VaccinationModel] from a raw map and document ID.
  factory VaccinationModel.fromMap(Map<String, dynamic> map, String id) {
    return VaccinationModel(
      id: id,
      petId: map['petId'] as String? ?? '',
      vaccineName: map['vaccineName'] as String? ?? '',
      dateGiven: _parseDateTime(map['dateGiven']),
      nextDueDate: _parseDateTime(map['nextDueDate']),
      vetId: map['vetId'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Construct a [VaccinationModel] directly from a Firestore [DocumentSnapshot].
  factory VaccinationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return VaccinationModel.fromMap(doc.data() ?? {}, doc.id);
  }

  /// Convert to Firestore map representation matching schema specification.
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

  /// Create a copy with optional overridden fields.
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
