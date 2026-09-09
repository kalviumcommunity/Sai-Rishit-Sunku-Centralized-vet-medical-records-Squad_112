import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final DateTime dateOfBirth;
  final String microchipId;
  final String ownerId;
  final String? photoUrl;
  final DateTime createdAt;

  const PetModel({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    required this.microchipId,
    required this.ownerId,
    this.photoUrl,
    required this.createdAt,
  });

  int get ageYears {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years > 0 ? years : 0;
  }

  factory PetModel.fromMap(Map<String, dynamic> map, String id) {
    return PetModel(
      id: id,
      name: map['name'] as String? ?? '',
      species: map['species'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      gender: map['gender'] as String? ?? 'unknown',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      microchipId: map['microchipId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory PetModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return PetModel.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'microchipId': microchipId,
      'ownerId': ownerId,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PetModel copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? gender,
    DateTime? dateOfBirth,
    String? microchipId,
    String? ownerId,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      microchipId: microchipId ?? this.microchipId,
      ownerId: ownerId ?? this.ownerId,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
