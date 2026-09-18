import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a veterinary clinic branch location in the centralized network.
///
/// [isHub] indicates if the location is a 24/7 central emergency hospital hub
/// or a satellite clinic branch.
class BranchModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isHub;
  final DateTime createdAt;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isHub,
    required this.createdAt,
  });

  /// Helper parser to handle various timestamp formats safely (Timestamp, DateTime, int, or String).
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Construct a [BranchModel] from a plain map and a document ID.
  factory BranchModel.fromMap(Map<String, dynamic> map, String id) {
    return BranchModel(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      isHub: map['isHub'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Construct a [BranchModel] directly from a Firestore [DocumentSnapshot].
  factory BranchModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return BranchModel.fromMap(doc.data() ?? {}, doc.id);
  }

  /// Convert to Firestore map representation matching schema specification.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'isHub': isHub,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with optional overridden fields.
  BranchModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    bool? isHub,
    DateTime? createdAt,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isHub: isHub ?? this.isHub,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
