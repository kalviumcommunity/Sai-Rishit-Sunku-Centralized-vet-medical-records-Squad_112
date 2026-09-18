import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a digital medical record attachment (lab report, X-ray scan, prescription PDF)
/// stored in Firebase Storage and indexed in Cloud Firestore.
///
/// Follows the pet across clinic branches for cross-branch discovery.
class MedicalDocumentModel {
  final String id;
  final String petId;
  final String fileName;
  final String fileUrl;
  final String uploadedBy;
  final String branchId;
  final DateTime createdAt;

  const MedicalDocumentModel({
    required this.id,
    required this.petId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedBy,
    required this.branchId,
    required this.createdAt,
  });

  bool get isPdf => fileName.toLowerCase().endsWith('.pdf');
  bool get isImage =>
      fileName.toLowerCase().endsWith('.png') ||
      fileName.toLowerCase().endsWith('.jpg') ||
      fileName.toLowerCase().endsWith('.jpeg') ||
      fileName.toLowerCase().endsWith('.webp');

  /// Helper parser to handle various timestamp formats safely (Timestamp, DateTime, int, or String).
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Construct a [MedicalDocumentModel] from a plain map and a document ID.
  factory MedicalDocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicalDocumentModel(
      id: id,
      petId: map['petId'] as String? ?? '',
      fileName: map['fileName'] as String? ?? '',
      fileUrl: map['fileUrl'] as String? ?? '',
      uploadedBy: map['uploadedBy'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Construct a [MedicalDocumentModel] directly from a Firestore [DocumentSnapshot].
  factory MedicalDocumentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return MedicalDocumentModel.fromMap(doc.data() ?? {}, doc.id);
  }

  /// Convert to Firestore map representation matching schema specification.
  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'branchId': branchId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with optional overridden fields.
  MedicalDocumentModel copyWith({
    String? id,
    String? petId,
    String? fileName,
    String? fileUrl,
    String? uploadedBy,
    String? branchId,
    DateTime? createdAt,
  }) {
    return MedicalDocumentModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
