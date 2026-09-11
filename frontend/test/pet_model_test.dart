import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare/models/pet_model.dart';

void main() {
  group('PetModel Serialization & Validation Tests (Day 3)', () {
    test('toMap and fromMap should round-trip correctly with microchipId and timestamps', () {
      final dob = DateTime(2021, 5, 15);
      final createdAt = DateTime(2026, 9, 11, 10, 0, 0);

      final pet = PetModel(
        id: 'pet_milo_001',
        name: 'Milo',
        species: 'Dog',
        breed: 'Golden Retriever',
        gender: 'male',
        dateOfBirth: dob,
        microchipId: '985141001234567',
        ownerId: 'owner_alex_999',
        photoUrl: 'https://storage.googleapis.com/vetcare/pets/milo.jpg',
        createdAt: createdAt,
      );

      final map = pet.toMap();
      expect(map['name'], 'Milo');
      expect(map['species'], 'Dog');
      expect(map['breed'], 'Golden Retriever');
      expect(map['gender'], 'male');
      expect(map['microchipId'], '985141001234567');
      expect(map['ownerId'], 'owner_alex_999');
      expect(map['photoUrl'], 'https://storage.googleapis.com/vetcare/pets/milo.jpg');
      expect(map['dateOfBirth'], isA<Timestamp>());
      expect((map['dateOfBirth'] as Timestamp).toDate(), dob);
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), createdAt);

      final deserialized = PetModel.fromMap(map, 'pet_milo_001');
      expect(deserialized.id, pet.id);
      expect(deserialized.name, pet.name);
      expect(deserialized.species, pet.species);
      expect(deserialized.breed, pet.breed);
      expect(deserialized.gender, pet.gender);
      expect(deserialized.microchipId, '985141001234567');
      expect(deserialized.ownerId, pet.ownerId);
      expect(deserialized.photoUrl, pet.photoUrl);
      expect(deserialized.dateOfBirth, dob);
      expect(deserialized.createdAt, createdAt);
    });

    test('ageYears computes correctly based on dateOfBirth', () {
      final now = DateTime.now();
      final twoYearsAgo = DateTime(now.year - 2, now.month, now.day);
      final pet = PetModel(
        id: 'pet_age_test',
        name: 'Buddy',
        species: 'Cat',
        breed: 'Siamese',
        gender: 'female',
        dateOfBirth: twoYearsAgo,
        microchipId: '985141009999999',
        ownerId: 'owner_test',
        createdAt: now,
      );

      expect(pet.ageYears, 2);
    });

    test('copyWith properly updates fields while keeping microchipId intact', () {
      final pet = PetModel(
        id: 'pet_copy_test',
        name: 'Bella',
        species: 'Dog',
        breed: 'Beagle',
        gender: 'female',
        dateOfBirth: DateTime(2022, 1, 1),
        microchipId: '985141007777777',
        ownerId: 'owner_test',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = pet.copyWith(name: 'Bella Luna');
      expect(updated.name, 'Bella Luna');
      expect(updated.microchipId, '985141007777777');
      expect(updated.species, 'Dog');
      expect(updated.breed, 'Beagle');
    });
  });
}
