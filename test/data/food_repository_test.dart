import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/food_repository.dart';

void main() {
  late AppDatabase db;
  late FoodRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FoodRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insert then find by barcode returns the inserted food', () async {
    final id = await repo.insertFood(
      name: 'Test Yogurt',
      barcode: '1234567890123',
      kcalPer100g: 60,
      proteinPer100g: 5,
      fatPer100g: 2,
      carbsPer100g: 7,
      source: FoodSourceType.barcode,
    );

    final result = await repo.findByBarcode('1234567890123');

    expect(result, isNotNull);
    expect(result!.name, 'Test Yogurt');
    expect(result.existingPrivateFoodId, id);
  });

  test('stored favorites are exposed on FoodResult mappings', () async {
    await repo.insertFood(
      name: 'Favorite Yogurt',
      barcode: '999',
      kcalPer100g: 60,
      proteinPer100g: 5,
      fatPer100g: 2,
      carbsPer100g: 7,
      source: FoodSourceType.barcode,
      isFavorite: true,
    );

    final byBarcode = await repo.findByBarcode('999');
    final bySearch = await repo.searchByName('Favorite');

    expect(byBarcode, isNotNull);
    expect(byBarcode!.isFavorite, true);
    expect(bySearch.single.isFavorite, true);
  });

  test('findByBarcode prefers favorite rows when duplicate local barcodes exist', () async {
    await repo.insertFood(
      name: 'First Duplicate',
      barcode: 'dup-1',
      kcalPer100g: 60,
      proteinPer100g: 5,
      fatPer100g: 2,
      carbsPer100g: 7,
      source: FoodSourceType.barcode,
    );
    final favoriteId = await repo.insertFood(
      name: 'Second Duplicate',
      barcode: 'dup-1',
      kcalPer100g: 80,
      proteinPer100g: 6,
      fatPer100g: 3,
      carbsPer100g: 8,
      source: FoodSourceType.barcode,
      isFavorite: true,
    );

    final result = await repo.findByBarcode('dup-1');

    expect(result, isNotNull);
    expect(result!.existingPrivateFoodId, favoriteId);
    expect(result.name, 'Second Duplicate');
    expect(result.isFavorite, true);
  });

  test('insertFood defaults isFavorite to false and persists explicit true', () async {
    final defaultId = await repo.insertFood(
      name: 'Default Favorite',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
    );
    final explicitId = await repo.insertFood(
      name: 'Explicit Favorite',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
      isFavorite: true,
    );

    final foods = await db.select(db.privateFoods).get();
    expect(foods.firstWhere((f) => f.id == defaultId).isFavorite, false);
    expect(foods.firstWhere((f) => f.id == explicitId).isFavorite, true);
  });

  test('searchByName is case-insensitive and matches substrings', () async {
    await repo.insertFood(
      name: 'Greek Yogurt',
      kcalPer100g: 90,
      proteinPer100g: 10,
      fatPer100g: 4,
      carbsPer100g: 4,
      source: FoodSourceType.manual,
    );

    final results = await repo.searchByName('yogurt');

    expect(results, hasLength(1));
    expect(results.first.name, 'Greek Yogurt');
  });

  test('updateFood changes the stored macros', () async {
    final id = await repo.insertFood(
      name: 'Oats',
      kcalPer100g: 380,
      proteinPer100g: 13,
      fatPer100g: 7,
      carbsPer100g: 67,
      source: FoodSourceType.manual,
    );

    await repo.updateFood(
      id,
      name: 'Oats',
      kcalPer100g: 390,
      proteinPer100g: 13,
      fatPer100g: 7,
      carbsPer100g: 68,
    );

    final results = await repo.searchByName('Oats');
    expect(results.first.kcalPer100g, 390);
  });

  test('setFavorite, toggleFavorite, and updateFood preserve favorite state correctly', () async {
    final id = await repo.insertFood(
      name: 'Toggle Me',
      barcode: '200',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
    );

    await repo.setFavorite(id, true);
    expect((await repo.findByBarcode('200'))!.isFavorite, true);

    await repo.toggleFavorite(id);
    expect((await repo.findByBarcode('200'))!.isFavorite, false);

    await repo.updateFood(
      id,
      name: 'Toggle Me',
      barcode: '200',
      kcalPer100g: 120,
      proteinPer100g: 2,
      fatPer100g: 2,
      carbsPer100g: 2,
    );
    expect((await repo.findByBarcode('200'))!.isFavorite, false);
  });

  test('deleteFood removes it from search results', () async {
    final id = await repo.insertFood(
      name: 'Deleted Item',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
    );

    await repo.deleteFood(id);

    final results = await repo.searchByName('Deleted');
    expect(results, isEmpty);
  });

  test('getRecentFoods returns unique foods sorted by latest occurredAt and favorites filter', () async {
    final alphaId = await repo.insertFood(
      name: 'Alpha',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
      isFavorite: true,
    );
    final betaId = await repo.insertFood(
      name: 'Beta',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
    );
    final gammaId = await repo.insertFood(
      name: 'Gamma',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
    );

    final mealId = await db.into(db.meals).insert(
      MealsCompanion.insert(dayDate: DateTime(2026, 7, 15), mealNumber: 1),
    );

    Future<void> addDiary(int? privateFoodId, String name, DateTime occurredAt) {
      return db.into(db.diaryEntries).insert(
        DiaryEntriesCompanion.insert(
          mealId: mealId,
          privateFoodId: Value(privateFoodId),
          foodNameSnapshot: name,
          grams: 100,
          kcalSnapshot: 100,
          proteinSnapshot: 1,
          fatSnapshot: 1,
          carbsSnapshot: 1,
          occurredAt: occurredAt,
          createdAt: occurredAt,
          entryDate: DateTime(2026, 7, 15),
        ),
      );
    }

    await addDiary(alphaId, 'Alpha', DateTime(2026, 7, 15, 8, 0));
    await addDiary(alphaId, 'Alpha', DateTime(2026, 7, 15, 9, 0));
    await addDiary(betaId, 'Beta', DateTime(2026, 7, 15, 9, 0));
    await addDiary(null, 'Snapshot Only', DateTime(2026, 7, 15, 10, 0));

    final recent = await repo.getRecentFoods(favoritesOnly: false);
    final favoritesOnly = await repo.getRecentFoods(favoritesOnly: true);

    expect(recent.map((f) => f.name).toList(), ['Alpha', 'Beta']);
    expect(recent.where((f) => f.name == 'Alpha'), hasLength(1));
    expect(recent.any((f) => f.name == 'Gamma'), false);
    expect(favoritesOnly.map((f) => f.name).toList(), ['Alpha']);

    await repo.deleteFood(alphaId);
    final afterDelete = await repo.getRecentFoods(favoritesOnly: false);
    expect(afterDelete.map((f) => f.name).toList(), ['Beta']);

    expect(gammaId, greaterThan(0));
  });
}
