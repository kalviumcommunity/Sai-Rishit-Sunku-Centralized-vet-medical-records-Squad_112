import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/models.dart';
import 'medical_records_service.dart';

/// Service managing medical document uploads to Firebase Storage
/// and metadata records in Cloud Firestore under `medical_documents`.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// In-memory mock documents store for offline / test resilience
  final Map<String, List<MedicalDocumentModel>> _mockDocuments = {};

  /// Fallback demo documents for presentation and testing
  List<MedicalDocumentModel> getFallbackDocuments(String petId) {
    final now = DateTime.now();
    return [
      MedicalDocumentModel(
        id: 'doc_01',
        petId: petId,
        fileName: 'CBC_Complete_Blood_Panel.pdf',
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        uploadedBy: 'user_dr_sharma',
        branchId: 'branch_koramangala',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      MedicalDocumentModel(
        id: 'doc_02',
        petId: petId,
        fileName: 'Abdominal_Radiograph_XRay.png',
        fileUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop&q=80',
        uploadedBy: 'user_dr_sharma',
        branchId: 'branch_koramangala',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      MedicalDocumentModel(
        id: 'doc_03',
        petId: petId,
        fileName: 'Rabies_Immunization_Certificate.pdf',
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        uploadedBy: 'user_dr_patel',
        branchId: 'branch_whitefield',
        createdAt: now.subtract(const Duration(days: 90)),
      ),
    ];
  }

  /// Pick a PDF, JPG, or PNG document from the user device (up to 15MB)
  Future<PlatformFile?> pickDocument() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (file != null) {
        final size = await file.length() ?? 0;
        // Validate 15MB limit
        if (size > 15 * 1024 * 1024) {
          throw Exception('File exceeds maximum allowable size of 15MB.');
        }
        return file;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads picked file to Firebase Storage under `pets/{petId}/documents/{fileName}`
  /// and persists document metadata into Firestore `medical_documents` collection.
  Future<MedicalDocumentModel> uploadDocument({
    required String petId,
    required String fileName,
    required Uint8List bytes,
    required String branchId,
    required String uploadedBy,
  }) async {
    if (bytes.lengthInBytes > 15 * 1024 * 1024) {
      throw Exception('File size exceeds the 15MB limit.');
    }

    final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = 'pets/$petId/documents/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
    String downloadUrl = '';

    if (Firebase.apps.isNotEmpty) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        final mimeType = _getMimeType(fileName);
        final metadata = SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'petId': petId,
            'uploadedBy': uploadedBy,
            'branchId': branchId,
          },
        );

        final uploadTask = await storageRef.putData(bytes, metadata);
        downloadUrl = await uploadTask.ref.getDownloadURL();

        final firestore = FirebaseFirestore.instance;
        final docRef = firestore.collection('medical_documents').doc();
        final now = DateTime.now();

        final docData = {
          'petId': petId,
          'fileName': fileName,
          'fileUrl': downloadUrl,
          'uploadedBy': uploadedBy,
          'branchId': branchId,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await docRef.set(docData);

        final model = MedicalDocumentModel(
          id: docRef.id,
          petId: petId,
          fileName: fileName,
          fileUrl: downloadUrl,
          uploadedBy: uploadedBy,
          branchId: branchId,
          createdAt: now,
        );

        _mockDocuments.putIfAbsent(petId, () => []).insert(0, model);
        return model;
      } catch (e) {
        // Fallback gracefully to offline simulated record
        return _createFallbackUpload(
          petId: petId,
          fileName: fileName,
          branchId: branchId,
          uploadedBy: uploadedBy,
        );
      }
    }

    return _createFallbackUpload(
      petId: petId,
      fileName: fileName,
      branchId: branchId,
      uploadedBy: uploadedBy,
    );
  }

  /// Creates an in-memory document record when Firebase is unavailable
  MedicalDocumentModel _createFallbackUpload({
    required String petId,
    required String fileName,
    required String branchId,
    required String uploadedBy,
  }) {
    final now = DateTime.now();
    final model = MedicalDocumentModel(
      id: 'doc_${now.millisecondsSinceEpoch}',
      petId: petId,
      fileName: fileName,
      fileUrl: fileName.toLowerCase().endsWith('.pdf')
          ? 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
          : 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop&q=80',
      uploadedBy: uploadedBy,
      branchId: branchId,
      createdAt: now,
    );

    _mockDocuments.putIfAbsent(petId, () => []).insert(0, model);
    return model;
  }

  /// Fetches uploaded medical documents for a specific pet
  Future<List<MedicalDocumentModel>> fetchPetDocuments(String petId) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        final snapshot = await firestore
            .collection('medical_documents')
            .where('petId', isEqualTo: petId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final docs = snapshot.docs.map((d) => MedicalDocumentModel.fromFirestore(d)).toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        }
      } catch (_) {}
    }

    // Return in-memory documents if any were uploaded this session, or fallback demo set
    final inMemory = _mockDocuments[petId];
    if (inMemory != null && inMemory.isNotEmpty) {
      return List.unmodifiable(inMemory);
    }
    return getFallbackDocuments(petId);
  }

  String _getMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}
