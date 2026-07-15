import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/diary_repository.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository repo;
  const gapWindow = Duration(minutes: 90);
  final day = DateTime(2026, 7, 14);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DiaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> addEggs(DateTime occurredAt) => repo.addEntry(
        foodNameSnapshot: 'Eggs',
        grams: 100,
        kcalPer100g: 150,
        proteinPer100g: 12,
        fatPer100g: 10,
        carbsPer100g: 1,
        entryDate: day,
        occurredAt: occurredAt,
        gapWindow: gapWindow,
      );

  test('two entries within the gap land in the same meal', () async {
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    await addEggs(DateTime(2026, 7, 14, 8, 20));

    final meals = await repo.getMealsForDate(day);
    expect(meals, hasLength(1));
    expect(meals.first.mealNumber, 1);

    final entries = await repo.getEntriesForDate(day);
    expect(entries, hasLength(2));
    expect(entries.every((e) => e.mealId == meals.first.id), true);
  });

  test('entries past the gap create a second meal', () async {
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    await addEggs(DateTime(2026, 7, 14, 13, 0));

    final meals = await repo.getMealsForDate(day);
    expect(meals, hasLength(2));
    expect(meals.map((m) => m.mealNumber).toList(), [1, 2]);
  });

  test('addEntry stores a nutrition snapshot scaled to grams and stamps createdAt', () async {
    await repo.addEntry(
      foodNameSnapshot: 'Chicken Breast',
      grams: 150,
      kcalPer100g: 165,
      proteinPer100g: 31,
      fatPer100g: 3.6,
      carbsPer100g: 0,
      entryDate: day,
      occurredAt: DateTime(2026, 7, 14, 12, 0),
      gapWindow: gapWindow,
    );

    final entries = await repo.getEntriesForDate(day);
    expect(entries.single.kcalSnapshot, closeTo(247.5, 0.01));
    expect(entries.single.proteinSnapshot, closeTo(46.5, 0.01));
    expect(entries.single.createdAt, isNotNull);
    expect(entries.single.updatedAt, isNull);
  });

  test('adding an entry chronologically between two existing entries merges all three into one meal regardless of add order', () async {
    // Regression test for the "last non-manual meal" bug: the middle entry
    // is added last, after two entries that are already 90+ minutes apart at
    // the DB level from each other's perspective, but each neighbor is
    // within gapWindow of the middle entry.
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    await addEggs(DateTime(2026, 7, 14, 9, 0));
    await addEggs(DateTime(2026, 7, 14, 8, 30)); // added last, sorts in the middle

    final meals = await repo.getMealsForDate(day);
    expect(meals, hasLength(1));
    final entries = await repo.getEntriesForDate(day);
    expect(entries, hasLength(3));
  });

  test('updateEntryGrams rescales from the original snapshot ratio, not current food data', () async {
    final id = await repo.addEntry(
      foodNameSnapshot: 'Rice',
      grams: 100,
      kcalPer100g: 130,
      proteinPer100g: 3,
      fatPer100g: 0.3,
      carbsPer100g: 28,
      entryDate: day,
      occurredAt: DateTime(2026, 7, 14, 12, 0),
      gapWindow: gapWindow,
    );

    await repo.updateEntryGrams(id, 200);

    final entries = await repo.getEntriesForDate(day);
    expect(entries.single.grams, 200);
    expect(entries.single.kcalSnapshot, closeTo(260, 0.01));
    expect(entries.single.updatedAt, isNotNull);
  });

  test('moveEntryToMeal marks the target meal manual and deletes an emptied source meal', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final manualMealId = await repo.createManualMeal(day, 5);
    final sourceMealId =
        (await repo.getEntriesForDate(day)).single.mealId;

    await repo.moveEntryToMeal(entryId, manualMealId);

    final entries = await repo.getEntriesForDate(day);
    expect(entries.single.mealId, manualMealId);

    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == sourceMealId), false); // emptied source removed
    final manualMeal = meals.firstWhere((m) => m.id == manualMealId);
    expect(manualMeal.isManual, true);
  });

  test('updateEntryOccurredAt regroups the day but leaves manual meals untouched', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final manualMealId = await repo.createManualMeal(day, 99);
    final snackId = await addEggs(DateTime(2026, 7, 14, 16, 0));
    await repo.moveEntryToMeal(snackId, manualMealId);

    // Move the first entry far past the gap from its original meal.
    await repo.updateEntryOccurredAt(
      entryId,
      DateTime(2026, 7, 14, 20, 0),
      gapWindow,
    );

    final meals = await repo.getMealsForDate(day);
    final manualMeal = meals.firstWhere((m) => m.id == manualMealId);
    expect(manualMeal.isManual, true);
    expect(manualMeal.mealNumber, 99);

    final entries = await repo.getEntriesForDate(day);
    final movedEntry = entries.firstWhere((e) => e.id == entryId);
    expect(movedEntry.mealId, isNot(manualMealId));
  });

  test('deleteEntry removes the row and cleans up an emptied auto meal', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final mealId = (await repo.getEntriesForDate(day)).single.mealId;

    await repo.deleteEntry(entryId, gapWindow);

    expect(await repo.getEntriesForDate(day), isEmpty);
    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == mealId), false);
  });

  test('deleting the last entry in a manual meal removes that manual meal too', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final manualMealId = await repo.createManualMeal(day, 7);
    await repo.moveEntryToMeal(entryId, manualMealId);

    await repo.deleteEntry(entryId, gapWindow);

    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == manualMealId), false);
  });

  test('splitEntriesIntoNewMeal creates a manual meal and marks the source meal manual too', () async {
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    final secondId = await addEggs(DateTime(2026, 7, 14, 8, 20));
    final sourceMealId = (await repo.getEntriesForDate(day)).first.mealId;

    final newMealId = await repo.splitEntriesIntoNewMeal(
      entryIds: [secondId],
      date: day,
      newMealNumber: 50,
    );

    final meals = await repo.getMealsForDate(day);
    final newMeal = meals.firstWhere((m) => m.id == newMealId);
    expect(newMeal.isManual, true);
    final sourceMeal = meals.firstWhere((m) => m.id == sourceMealId);
    expect(sourceMeal.isManual, true); // touched by the split, so it's locked too

    final entries = await repo.getEntriesForDate(day);
    expect(entries.firstWhere((e) => e.id == secondId).mealId, newMealId);
  });

  test('mergeMeals combines two meals into one manual meal and deletes the other', () async {
    final firstId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final secondId = await addEggs(DateTime(2026, 7, 14, 13, 0));
    final entries = await repo.getEntriesForDate(day);
    final firstMealId = entries.firstWhere((e) => e.id == firstId).mealId;
    final secondMealId = entries.firstWhere((e) => e.id == secondId).mealId;

    await repo.mergeMeals(keepMealId: firstMealId, otherMealId: secondMealId);

    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == secondMealId), false);
    final keptMeal = meals.firstWhere((m) => m.id == firstMealId);
    expect(keptMeal.isManual, true);

    final updatedEntries = await repo.getEntriesForDate(day);
    expect(updatedEntries.every((e) => e.mealId == firstMealId), true);
  });
}
