import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a VetCare user profile (Owner, Vet, or Admin).
/// Unified across both Email/Password and Google Sign-In authentication providers.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'owner' | 'vet' | 'admin'
  final String? branchId;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.branchId,
    required this.createdAt,
  });

  bool get isOwner => role == 'owner';
  bool get isVet => role == 'vet';
  bool get isAdmin => role == 'admin';

  /// Helper parser to handle various timestamp formats safely (Timestamp, DateTime, int, or String)
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Construct a [UserModel] from a plain map and a document ID.
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'owner',
      branchId: map['branchId'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Construct a [UserModel] directly from a Firestore [DocumentSnapshot].
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromMap(doc.data() ?? {}, doc.id);
  }

  /// Convert to Firestore map representation matching schema specification.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'branchId': branchId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with optional overridden fields.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? branchId,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
