import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:callory/db/database.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/goals/goals_screen.dart';
import '../test_helpers.dart';

void main() {
  testWidgets('manual mode lets the user type kcal directly and save it', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
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
      child: wrapWithLocalizations(const GoalsScreen()),
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

    // Defaults: Sex.male, ActivityLevel.sedentary, GoalType.maintain.
    // bmr = 10*80 + 6.25*180 - 5*30 + 5 = 1780; tdee = 1780*1.2 = 2136.
    final goals = await db.select(db.goals).getSingleOrNull();
    expect(goals, isNotNull);
    expect(goals!.mode, GoalsMode.calculated);
    expect(goals.dailyKcal, closeTo(2136, 0.01));
    expect(goals.dailyProtein, closeTo(160.2, 0.01));
    expect(goals.dailyCarbs, closeTo(213.6, 0.01));

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

  testWidgets('switching to calculated mode does not leak leftover manual field values', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    // Type a manual kcal value, then switch modes before saving.
    await tester.enterText(find.byKey(const Key('manualKcalField')), '1800');
    await tester.tap(find.text('Calculated'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('calcAgeField')), '25');
    await tester.enterText(find.byKey(const Key('calcWeightField')), '60');
    await tester.enterText(find.byKey(const Key('calcHeightField')), '165');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    // bmr = 10*60 + 6.25*165 - 5*25 + 5 = 1511.25; tdee = 1511.25*1.2 = 1813.5.
    final allGoals = await db.select(db.goals).get();
    expect(allGoals, hasLength(1));
    expect(allGoals.single.mode, GoalsMode.calculated);
    expect(allGoals.single.dailyKcal, closeTo(1813.5, 0.01));
    expect(allGoals.single.dailyKcal, isNot(1800));

    await db.close();
  });

  testWidgets('manual save with empty fields stores zeros instead of crashing', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    final goals = await db.select(db.goals).getSingleOrNull();
    expect(goals, isNotNull);
    expect(goals!.mode, GoalsMode.manual);
    expect(goals.dailyKcal, 0);
    expect(goals.dailyProtein, 0);
    expect(goals.dailyFat, 0);
    expect(goals.dailyCarbs, 0);

    await db.close();
  });

  testWidgets('reopening Goals after saving calculated goals reloads the stored mode and values', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
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
      child: wrapWithLocalizations(const GoalsScreen()),
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
