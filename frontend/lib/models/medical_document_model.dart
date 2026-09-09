import 'package:cloud_firestore/cloud_firestore.dart';

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
      fileName.toLowerCase().endsWith('.jpeg');

  factory MedicalDocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicalDocumentModel(
      id: id,
      petId: map['petId'] as String? ?? '',
      fileName: map['fileName'] as String? ?? '',
      fileUrl: map['fileUrl'] as String? ?? '',
      uploadedBy: map['uploadedBy'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MedicalDocumentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return MedicalDocumentModel.fromMap(doc.data() ?? {}, doc.id);
  }

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
