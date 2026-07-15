import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/data/diary_repository.dart';
import 'package:callory/data/goals_repository.dart';
import 'package:callory/domain/bmr_calculator.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/day/day_screen.dart';

void main() {
  testWidgets('shows an empty state with no meals logged for the day', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: const MaterialApp(home: DayScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No meals logged yet'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows a logged entry grouped under its meal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final diaryRepo = DiaryRepository(db);
    final today = DateTime.now();
    await diaryRepo.addEntry(
      foodNameSnapshot: 'Test Meal Item',
      grams: 100,
      kcalPer100g: 150,
      proteinPer100g: 10,
      fatPer100g: 5,
      carbsPer100g: 10,
      entryDate: DateTime(today.year, today.month, today.day),
      occurredAt: today,
      gapWindow: const Duration(minutes: 90),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: const MaterialApp(home: DayScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Test Meal Item'), findsOneWidget);
    expect(find.textContaining('Прием 1'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows calculated goal progress even with no meals logged yet', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final goalsRepo = GoalsRepository(db);
    await goalsRepo.setCalculatedGoals(const BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: const MaterialApp(home: DayScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No meals logged yet'), findsOneWidget);
    expect(find.text('Kcal'), findsOneWidget);

    await db.close();
  });
}
