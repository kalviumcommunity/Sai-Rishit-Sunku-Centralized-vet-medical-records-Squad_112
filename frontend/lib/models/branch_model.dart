import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory BranchModel.fromMap(Map<String, dynamic> map, String id) {
    return BranchModel(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      isHub: map['isHub'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BranchModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return BranchModel.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'isHub': isHub,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

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
