import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/export_import_service.dart';

void main() {
  test('export then import round-trips all four tables into a fresh database', () async {
    final sourceDb = AppDatabase.forTesting(NativeDatabase.memory());

    final foodId = await sourceDb.into(sourceDb.privateFoods).insert(
          PrivateFoodsCompanion.insert(
            name: 'Rice',
            kcalPer100g: 130,
            proteinPer100g: 3,
            fatPer100g: 0.3,
            carbsPer100g: 28,
            source: FoodSourceType.manual,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    final mealId = await sourceDb.into(sourceDb.meals).insert(
          MealsCompanion.insert(dayDate: DateTime(2026, 7, 14), mealNumber: 1),
        );
    await sourceDb.into(sourceDb.diaryEntries).insert(
          DiaryEntriesCompanion.insert(
            mealId: mealId,
            privateFoodId: Value(foodId),
            foodNameSnapshot: 'Rice',
            grams: 200,
            kcalSnapshot: 260,
            proteinSnapshot: 6,
            fatSnapshot: 0.6,
            carbsSnapshot: 56,
            occurredAt: DateTime(2026, 7, 14, 12, 0),
            createdAt: DateTime(2026, 7, 14, 12, 0),
            entryDate: DateTime(2026, 7, 14),
          ),
        );
    await sourceDb.into(sourceDb.goals).insert(
          GoalsCompanion.insert(
            dailyKcal: 2200,
            dailyProtein: 150,
            dailyFat: 70,
            dailyCarbs: 220,
            mode: GoalsMode.manual,
          ),
        );

    final exportService = ExportImportService(sourceDb);
    final json = await exportService.exportToJson();
    await sourceDb.close();

    final targetDb = AppDatabase.forTesting(NativeDatabase.memory());
    final importService = ExportImportService(targetDb);
    await importService.importFromJson(json);

    final foods = await targetDb.select(targetDb.privateFoods).get();
    final meals = await targetDb.select(targetDb.meals).get();
    final entries = await targetDb.select(targetDb.diaryEntries).get();
    final goals = await targetDb.select(targetDb.goals).get();

    expect(foods, hasLength(1));
    expect(foods.single.name, 'Rice');
    expect(meals, hasLength(1));
    expect(entries, hasLength(1));
    expect(entries.single.kcalSnapshot, 260);
    expect(goals, hasLength(1));
    expect(goals.single.dailyKcal, 2200);

    await targetDb.close();
  });

  test('importFromJson rejects an unknown format version', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = ExportImportService(db);

    expect(
      () => service.importFromJson({'formatVersion': 999}),
      throwsFormatException,
    );

    await db.close();
  });

  test('importFromJson fully replaces existing data rather than merging', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = ExportImportService(db);

    await db.into(db.privateFoods).insert(PrivateFoodsCompanion.insert(
          name: 'Old Food',
          kcalPer100g: 1,
          proteinPer100g: 1,
          fatPer100g: 1,
          carbsPer100g: 1,
          source: FoodSourceType.manual,
          createdAt: DateTime(2026, 1, 1),
        ));

    await service.importFromJson({
      'formatVersion': ExportImportService.formatVersion,
      'privateFoods': [],
      'meals': [],
      'diaryEntries': [],
      'goals': [],
    });

    final foods = await db.select(db.privateFoods).get();
    expect(foods, isEmpty);

    await db.close();
  });
}
