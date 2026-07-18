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
      expect(find.text('300 kcal'), findsOneWidget);

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

      // Meal 2 (Lunch A) is newest, so it sorts first and is expanded by
      // default; Meal 1 (Breakfast A/B) is older, sorts second, and starts
      // collapsed — its entries aren't in the tree until its header is tapped.
      expect(find.textContaining('Meal 1'), findsOneWidget);
      expect(find.textContaining('Meal 2'), findsOneWidget);
      expect(
        tester.getTopLeft(find.textContaining('Meal 2')).dy,
        lessThan(tester.getTopLeft(find.textContaining('Meal 1')).dy),
      );
      expect(find.textContaining('Lunch A'), findsOneWidget);
      expect(find.textContaining('Breakfast A'), findsNothing);
      expect(find.textContaining('Breakfast B'), findsNothing);

      await tester.tap(find.textContaining('Meal 1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Breakfast A'), findsOneWidget);
      expect(find.textContaining('Breakfast B'), findsOneWidget);

      await db.close();
    },
  );

  testWidgets(
    'meal header shows the total kcal and macros for all its entries, even while collapsed',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final diaryRepo = DiaryRepository(db);
      final today = DateTime.now();
      final dayStart = DateTime(today.year, today.month, today.day);
      const gapWindow = Duration(minutes: 90);

      // Meal 1 (Oats+Milk) is older -> sorts second -> starts collapsed.
      await diaryRepo.addEntry(
        foodNameSnapshot: 'Oats',
        grams: 100,
        kcalPer100g: 150,
        proteinPer100g: 10,
        fatPer100g: 5,
        carbsPer100g: 10,
        entryDate: dayStart,
        occurredAt: dayStart.add(const Duration(hours: 8)),
        gapWindow: gapWindow,
      );
      await diaryRepo.addEntry(
        foodNameSnapshot: 'Milk',
        grams: 100,
        kcalPer100g: 60,
        proteinPer100g: 3,
        fatPer100g: 3,
        carbsPer100g: 5,
        entryDate: dayStart,
        occurredAt: dayStart.add(const Duration(hours: 8, minutes: 10)),
        gapWindow: gapWindow,
      );
      // Meal 2 (Salad) is newest -> sorts first -> starts expanded.
      await diaryRepo.addEntry(
        foodNameSnapshot: 'Salad',
        grams: 100,
        kcalPer100g: 90,
        proteinPer100g: 4,
        fatPer100g: 2,
        carbsPer100g: 12,
        entryDate: dayStart,
        occurredAt: dayStart.add(const Duration(hours: 14)),
        gapWindow: gapWindow,
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

      // Meal 1 is collapsed -> its entries aren't in the tree ...
      expect(find.textContaining('Oats'), findsNothing);
      // ... but its total is still shown on the (still-visible) header.
      expect(find.text('Σ 210 kcal · 13/8/15 P/F/C'), findsOneWidget);

      // Meal 2 is expanded; its total is also shown, distinct from its
      // single entry's own "90 kcal" line.
      expect(find.text('90 kcal'), findsOneWidget);
      expect(find.text('Σ 90 kcal · 4/2/12 P/F/C'), findsOneWidget);

      await db.close();
    },
  );

  testWidgets(
    'tapping the app bar date opens a datepicker that jumps to the picked day',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
            selectedDayProvider.overrideWith((ref) => DateTime(2026, 7, 15)),
          ],
          child: wrapWithLocalizations(const DayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2026-07-15'), findsOneWidget);

      await tester.tap(find.text('2026-07-15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      expect(find.text('2026-07-20'), findsOneWidget);

      await db.close();
    },
  );

  testWidgets(
    'deleting a logged entry shows a confirmation and removes it on confirm',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final diaryRepo = DiaryRepository(db);
      final today = DateTime.now();
      await diaryRepo.addEntry(
        foodNameSnapshot: 'Doomed Snack',
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

      expect(find.textContaining('Doomed Snack'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(
        find.text('Doomed Snack will be removed from this meal. Confirm?'),
        findsOneWidget,
      );

      // Cancel first: entry stays.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Doomed Snack'), findsOneWidget);
      expect(await db.select(db.diaryEntries).get(), hasLength(1));

      // Now delete for real.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Doomed Snack'), findsNothing);
      expect(await db.select(db.diaryEntries).get(), isEmpty);

      await db.close();
    },
  );
}
