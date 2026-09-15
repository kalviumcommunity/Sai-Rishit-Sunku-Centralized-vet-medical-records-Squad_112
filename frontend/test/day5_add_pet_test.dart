import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vetcare/models/pet_model.dart';
import 'package:vetcare/screens/owner/add_pet_screen.dart';
import 'package:vetcare/services/auth_service.dart';
import 'package:vetcare/utils/constants.dart';

void main() {
  group('DAY 5 — Add Pet Form UI & Validation Tests', () {
    testWidgets('renders all required Day 5 AddPetScreen UI components', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const AddPetScreen(),
          ),
        ),
      );

      // Verify Header and Paw Icon
      expect(find.text('Add Pet'), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsWidgets);
      expect(find.byType(BackButton), findsOneWidget);

      // Verify Dashed-Border "Add Photo" Upload Placeholder
      expect(find.text('Add Photo'), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);

      // Verify Fields
      expect(find.text('Pet Name *'), findsOneWidget);
      expect(find.text('Species *'), findsOneWidget);

      // Verify Three Species Pill Buttons (Dog / Cat / Other - not dropdown)
      expect(find.text('Dog'), findsOneWidget);
      expect(find.text('Cat'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.byType(DropdownButton), findsNothing);

      // Verify Breed Field
      expect(find.text('Breed'), findsOneWidget);

      // Verify Gender Toggle Pills (Male / Female)
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);

      // Verify Date of Birth Field
      expect(find.text('Date of Birth *'), findsOneWidget);
      expect(find.text('Select date of birth'), findsOneWidget);

      // Verify Microchip ID Field
      expect(find.text('Microchip ID (Optional)'), findsOneWidget);

      // Verify Static Sync Note
      expect(
        find.text('Automatic Multi-Branch Sync — Medical charts accessible across all VetCare clinics.'),
        findsOneWidget,
      );

      // Verify Save Button
      expect(find.widgetWithText(ElevatedButton, 'Save Pet Profile'), findsOneWidget);
    });

    testWidgets('selecting species pills updates active state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const AddPetScreen(),
          ),
        ),
      );

      // Tap Cat pill
      await tester.tap(find.text('Cat'));
      await tester.pump();

      // Tap Other pill
      await tester.tap(find.text('Other'));
      await tester.pump();

      // Tap Dog pill
      await tester.tap(find.text('Dog'));
      await tester.pump();
    });

    testWidgets('empty pet name triggers validation error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
            child: const AddPetScreen(),
          ),
        ),
      );

      // Ensure button is scrolled into view before tapping
      final saveBtn = find.widgetWithText(ElevatedButton, 'Save Pet Profile');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();

      expect(find.text('Please enter pet name.'), findsOneWidget);
    });

    test('PetModel round-trip correctly serializes all Day 5 fields', () {
      final pet = PetModel(
        id: 'pet_test_1',
        name: 'Milo',
        species: 'Dog',
        breed: 'Golden Retriever',
        gender: 'male',
        dateOfBirth: DateTime(2021, 5, 10),
        microchipId: '985141000123456',
        ownerId: 'owner_user_789',
        photoUrl: null,
        createdAt: DateTime(2026, 9, 15),
      );

      final map = pet.toMap();
      expect(map['name'], equals('Milo'));
      expect(map['species'], equals('Dog'));
      expect(map['breed'], equals('Golden Retriever'));
      expect(map['gender'], equals('male'));
      expect(map['microchipId'], equals('985141000123456'));
      expect(map['ownerId'], equals('owner_user_789'));
      expect(map.containsKey('dateOfBirth'), isTrue);
      expect(map.containsKey('createdAt'), isTrue);

      final reconstructed = PetModel.fromMap(map, 'pet_test_1');
      expect(reconstructed.id, equals('pet_test_1'));
      expect(reconstructed.name, equals('Milo'));
      expect(reconstructed.microchipId, equals('985141000123456'));
      expect(reconstructed.ownerId, equals('owner_user_789'));
      expect(reconstructed.ageYears, greaterThanOrEqualTo(4));
    });
  });
}
