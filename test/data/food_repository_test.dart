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
}
