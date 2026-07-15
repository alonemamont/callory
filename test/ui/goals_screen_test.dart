import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:callory/db/database.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/goals/goals_screen.dart';

void main() {
  testWidgets('manual mode lets the user type kcal directly and save it', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    // Manual mode is the default; enter a kcal value and save.
    await tester.enterText(find.byKey(const Key('manualKcalField')), '2200');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    final goals = await db.select(db.goals).getSingleOrNull();
    expect(goals, isNotNull);
    expect(goals!.dailyKcal, 2200);
    expect(goals.mode, GoalsMode.manual);

    await db.close();
  });

  testWidgets('calculated mode computes goals on save and fills the manual fields for override', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculated'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('calcAgeField')), '30');
    await tester.enterText(find.byKey(const Key('calcWeightField')), '80');
    await tester.enterText(find.byKey(const Key('calcHeightField')), '180');
    // sex=male, activity=sedentary, goal=maintain are the defaults.

    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    // The DB should hold the BMR-derived numbers, not zeros.
    final goals = await db.select(db.goals).getSingleOrNull();
    expect(goals, isNotNull);
    expect(goals!.mode, GoalsMode.calculated);
    expect(goals.dailyKcal, greaterThan(0));

    // Flipping to Manual within the same session should show the computed
    // numbers as editable starting values (per spec: overriding them switches
    // the record to manual mode).
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    final kcalField = tester.widget<TextField>(find.byKey(const Key('manualKcalField')));
    final kcalShown = double.parse(kcalField.controller!.text);
    expect(kcalShown, closeTo(goals.dailyKcal, 0.5));

    await db.close();
  });

  testWidgets('reopening Goals after saving calculated goals reloads the stored mode and values', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculated'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('calcAgeField')), '30');
    await tester.enterText(find.byKey(const Key('calcWeightField')), '80');
    await tester.enterText(find.byKey(const Key('calcHeightField')), '180');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    final saved = await db.select(db.goals).getSingleOrNull();

    // Simulate navigating away and back: the home shell in main.dart swaps
    // the tab body by replacing the widget (not an IndexedStack), so the
    // GoalsScreen state is disposed and rebuilt from scratch when the user
    // returns to the tab.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    // Should reopen on the Calculated tab with the saved profile inputs.
    final ageField = tester.widget<TextField>(find.byKey(const Key('calcAgeField')));
    expect(ageField.controller!.text, '30');

    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();
    final kcalField = tester.widget<TextField>(find.byKey(const Key('manualKcalField')));
    expect(double.parse(kcalField.controller!.text), closeTo(saved!.dailyKcal, 0.5));

    await db.close();
  });
}
