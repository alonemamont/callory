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
import '../test_helpers.dart';

void main() {
  testWidgets('shows an empty state with no meals logged for the day', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: wrapWithLocalizations(const DayScreen()),
      ),
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: wrapWithLocalizations(const DayScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Test Meal Item'), findsOneWidget);
    expect(find.textContaining('Meal 1'), findsOneWidget);
    expect(find.text('150 kcal'), findsOneWidget);
    expect(find.text('10/5/10 P/F/C'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows calculated goal progress even with no meals logged yet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final goalsRepo = GoalsRepository(db);
    await goalsRepo.setCalculatedGoals(
      const BmrInput(
        sex: Sex.male,
        age: 30,
        weightKg: 80,
        heightCm: 180,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.maintain,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: wrapWithLocalizations(const DayScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No meals logged yet'), findsOneWidget);
    expect(find.text('Kcal'), findsOneWidget);

    await db.close();
  });

  testWidgets(
    'navigating to next day shows that day\'s entries, not today\'s',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final diaryRepo = DiaryRepository(db);
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      await diaryRepo.addEntry(
        foodNameSnapshot: 'Today Item',
        grams: 100,
        kcalPer100g: 150,
        proteinPer100g: 10,
        fatPer100g: 5,
        carbsPer100g: 10,
        entryDate: todayStart,
        occurredAt: todayStart.add(const Duration(hours: 8)),
        gapWindow: const Duration(minutes: 90),
      );
      await diaryRepo.addEntry(
        foodNameSnapshot: 'Tomorrow Item',
        grams: 100,
        kcalPer100g: 150,
        proteinPer100g: 10,
        fatPer100g: 5,
        carbsPer100g: 10,
        entryDate: tomorrowStart,
        occurredAt: tomorrowStart.add(const Duration(hours: 8)),
        gapWindow: const Duration(minutes: 90),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: wrapWithLocalizations(const DayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Today Item'), findsOneWidget);
      expect(find.textContaining('Tomorrow Item'), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tomorrow Item'), findsOneWidget);
      expect(find.textContaining('Today Item'), findsNothing);

      await db.close();
    },
  );

  testWidgets(
    'tapping a logged entry opens an edit dialog that updates grams',
    (tester) async {
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: wrapWithLocalizations(const DayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Test Meal Item'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editEntryGramsField')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('editEntryGramsField')),
        '200',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('200 g'), findsOneWidget);
      expect(find.textContaining('300 kcal'), findsOneWidget);

      await db.close();
    },
  );

  testWidgets(
    'entries within the gap window group into one meal, entries beyond it split into another',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final diaryRepo = DiaryRepository(db);
      final today = DateTime.now();
      final dayStart = DateTime(today.year, today.month, today.day);
      const gapWindow = Duration(minutes: 90);

      Future<void> addAt(String name, Duration offset) => diaryRepo.addEntry(
        foodNameSnapshot: name,
        grams: 100,
        kcalPer100g: 150,
        proteinPer100g: 10,
        fatPer100g: 5,
        carbsPer100g: 10,
        entryDate: dayStart,
        occurredAt: dayStart.add(offset),
        gapWindow: gapWindow,
      );

      await addAt('Breakfast A', const Duration(hours: 8));
      await addAt('Breakfast B', const Duration(hours: 8, minutes: 30));
      await addAt('Lunch A', const Duration(hours: 14));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: wrapWithLocalizations(const DayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Meal 1'), findsOneWidget);
      expect(find.textContaining('Meal 2'), findsOneWidget);
      expect(find.textContaining('Breakfast A'), findsOneWidget);
      expect(find.textContaining('Breakfast B'), findsOneWidget);
      expect(find.textContaining('Lunch A'), findsOneWidget);

      await db.close();
    },
  );
}
