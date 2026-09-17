import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a patient pet in the VetCare network.
///
/// Medical records (treatments, vaccinations, documents) are associated with
/// this entity and follow the pet seamlessly across all clinic branches.
/// The [microchipId] serves as a permanent, write-once ISO identifier.
class PetModel {
  final String id;
  final String name;
  final String nameLower;
  final String species;
  final String breed;
  final String gender;
  final DateTime dateOfBirth;
  final String microchipId;
  final String ownerId;
  final String? photoUrl;
  final double? weightKg;
  final DateTime createdAt;

  PetModel({
    required this.id,
    required this.name,
    String? nameLower,
    required this.species,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    required this.microchipId,
    required this.ownerId,
    this.photoUrl,
    this.weightKg,
    required this.createdAt,
  }) : nameLower = nameLower ?? name.toLowerCase();

  /// Computes the pet's age in whole years.
  int get ageYears {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years > 0 ? years : 0;
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

  /// Construct a [PetModel] from a plain map and a document ID.
  factory PetModel.fromMap(Map<String, dynamic> map, String id) {
    final rawName = map['name'] as String? ?? '';
    return PetModel(
      id: id,
      name: rawName,
      nameLower: map['nameLower'] as String? ?? rawName.toLowerCase(),
      species: map['species'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      gender: map['gender'] as String? ?? 'unknown',
      dateOfBirth: _parseDateTime(map['dateOfBirth']),
      microchipId: map['microchipId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? (map['weight'] as num?)?.toDouble(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Construct a [PetModel] directly from a Firestore [DocumentSnapshot].
  factory PetModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return PetModel.fromMap(doc.data() ?? {}, doc.id);
  }

  /// Convert to Firestore map representation matching schema specification.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameLower': nameLower.isNotEmpty ? nameLower : name.toLowerCase(),
      'species': species,
      'breed': breed,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'microchipId': microchipId,
      'ownerId': ownerId,
      'photoUrl': photoUrl,
      if (weightKg != null) 'weightKg': weightKg,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with optional overridden fields.
  PetModel copyWith({
    String? id,
    String? name,
    String? nameLower,
    String? species,
    String? breed,
    String? gender,
    DateTime? dateOfBirth,
    String? microchipId,
    String? ownerId,
    String? photoUrl,
    double? weightKg,
    DateTime? createdAt,
  }) {
    final updatedName = name ?? this.name;
    return PetModel(
      id: id ?? this.id,
      name: updatedName,
      nameLower: nameLower ?? (name != null ? updatedName.toLowerCase() : this.nameLower),
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      microchipId: microchipId ?? this.microchipId,
      ownerId: ownerId ?? this.ownerId,
      photoUrl: photoUrl ?? this.photoUrl,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
