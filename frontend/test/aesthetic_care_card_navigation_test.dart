import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare/widgets/aesthetic_care_card.dart';

void main() {
  group('AestheticCareCard — Food, Play, Care, Health Dynamic Navigation & Action Tests', () {
    testWidgets('Toggling tabs dynamically updates content, categories, and triggers respective interactive sheets', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool recordsOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AestheticCareCard(
                onOpenRecords: () {
                  recordsOpened = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Initial State defaults to Food (index 0)
      expect(find.text('Milo'), findsOneWidget);
      expect(find.text('DIET & NUTRITION'), findsOneWidget);
      expect(find.text('Log Meal'), findsOneWidget);
      expect(find.textContaining('Royal Canin Dachshund Adult'), findsOneWidget);

      // Tap "Log Meal" button -> opens interactive meal sheet
      await tester.tap(find.text('Log Meal'));
      await tester.pumpAndSettle();

      expect(find.text('Log Meal for Milo'), findsOneWidget);
      expect(find.text('Save Meal Entry'), findsOneWidget);

      // Save meal
      await tester.tap(find.text('Save Meal Entry'));
      await tester.pumpAndSettle();

      // Verify card dynamically reflects logged meal
      expect(find.text('Fed Today'), findsOneWidget);
      expect(find.textContaining('Dinner (90g) logged'), findsOneWidget);

      // 2. Navigate to "Play" tab
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();

      expect(find.text('DAILY EXERCISE & AGILITY'), findsOneWidget);
      expect(find.text('Start Play'), findsOneWidget);
      expect(find.textContaining('spine protection protocol'), findsOneWidget);

      // Tap "Start Play" -> opens activity session sheet
      await tester.tap(find.text('Start Play'));
      await tester.pumpAndSettle();

      expect(find.text('Activity Session for Milo'), findsOneWidget);
      await tester.tap(find.text('Complete & Record Session'));
      await tester.pumpAndSettle();

      expect(find.text('Goal Reached'), findsOneWidget);
      expect(find.textContaining('Park Walk completed'), findsOneWidget);

      // 3. Navigate to "Care" tab
      await tester.tap(find.text('Care'));
      await tester.pumpAndSettle();

      expect(find.text('WELLNESS & GROOMING'), findsOneWidget);
      expect(find.text('Care Log'), findsOneWidget);

      // Tap "Care Log" -> opens grooming checklist
      await tester.tap(find.text('Care Log'));
      await tester.pumpAndSettle();

      expect(find.text('Care & Grooming for Milo'), findsOneWidget);
      await tester.tap(find.text('Save Care Routine'));
      await tester.pumpAndSettle();

      expect(find.text('Care Verified'), findsOneWidget);

      // 4. Navigate to "Health" tab
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      expect(find.text('CLINICAL HEALTH RECORD'), findsOneWidget);
      expect(find.text('Health Chart'), findsOneWidget);

      // Tap "Health Chart" -> triggers onOpenRecords callback
      await tester.tap(find.text('Health Chart'));
      await tester.pumpAndSettle();

      expect(recordsOpened, isTrue);
    });
  });
}
