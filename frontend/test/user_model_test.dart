import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare/models/user_model.dart';

void main() {
  group('UserModel Serialization & Validation Tests', () {
    test('toMap and fromMap should round-trip correctly with Firestore Timestamp', () {
      final now = DateTime(2026, 9, 10, 12, 0, 0);
      final user = UserModel(
        id: 'usr_test_123',
        name: 'Dr. Sarah Smith',
        email: 'sarah.smith@vetcare.com',
        role: 'vet',
        branchId: 'branch_central_01',
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['name'], 'Dr. Sarah Smith');
      expect(map['email'], 'sarah.smith@vetcare.com');
      expect(map['role'], 'vet');
      expect(map['branchId'], 'branch_central_01');
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), now);

      final deserialized = UserModel.fromMap(map, 'usr_test_123');
      expect(deserialized.id, user.id);
      expect(deserialized.name, user.name);
      expect(deserialized.email, user.email);
      expect(deserialized.role, user.role);
      expect(deserialized.branchId, user.branchId);
      expect(deserialized.createdAt, now);
      expect(deserialized.isVet, isTrue);
      expect(deserialized.isOwner, isFalse);
      expect(deserialized.isAdmin, isFalse);
    });

    test('toMap handles nullable branchId for pet owners', () {
      final now = DateTime(2026, 9, 10, 10, 30, 0);
      final owner = UserModel(
        id: 'owner_google_456',
        name: 'John Doe',
        email: 'john.doe@gmail.com',
        role: 'owner',
        branchId: null,
        createdAt: now,
      );

      final map = owner.toMap();
      expect(map['branchId'], isNull);
      expect(owner.isOwner, isTrue);
      expect(owner.isVet, isFalse);
      expect(owner.isAdmin, isFalse);

      final deserialized = UserModel.fromMap(map, 'owner_google_456');
      expect(deserialized.branchId, isNull);
      expect(deserialized.name, 'John Doe');
    });

    test('copyWith properly updates selective fields while maintaining immutability', () {
      final original = UserModel(
        id: 'usr_orig',
        name: 'Original Name',
        email: 'orig@vetcare.com',
        role: 'owner',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(name: 'Updated Name');
      expect(updated.id, original.id);
      expect(updated.name, 'Updated Name');
      expect(updated.email, original.email);
      expect(updated.role, original.role);
    });
  });
}
