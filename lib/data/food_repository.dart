import 'package:drift/drift.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';

class FoodRepository implements FoodSource {
  final AppDatabase db;
  FoodRepository(this.db);

  Future<int> insertFood({
    required String name,
    String? barcode,
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    required FoodSourceType source,
  }) {
    return db.into(db.privateFoods).insert(PrivateFoodsCompanion.insert(
          name: name,
          barcode: Value(barcode),
          kcalPer100g: kcalPer100g,
          proteinPer100g: proteinPer100g,
          fatPer100g: fatPer100g,
          carbsPer100g: carbsPer100g,
          source: source,
          createdAt: DateTime.now(),
        ));
  }

  Future<void> updateFood(
    int id, {
    required String name,
    String? barcode,
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
  }) {
    return (db.update(db.privateFoods)..where((f) => f.id.equals(id))).write(
      PrivateFoodsCompanion(
        name: Value(name),
        barcode: Value(barcode),
        kcalPer100g: Value(kcalPer100g),
        proteinPer100g: Value(proteinPer100g),
        fatPer100g: Value(fatPer100g),
        carbsPer100g: Value(carbsPer100g),
      ),
    );
  }

  Future<void> deleteFood(int id) =>
      (db.delete(db.privateFoods)..where((f) => f.id.equals(id))).go();

  Future<FoodResult?> findByBarcode(String barcode) async {
    final row = await (db.select(db.privateFoods)
          ..where((f) => f.barcode.equals(barcode)))
        .getSingleOrNull();
    return row == null ? null : _toResult(row);
  }

  @override
  Future<FoodResult?> lookupBarcode(String barcode) => findByBarcode(barcode);

  @override
  Future<List<FoodResult>> searchByName(String query) async {
    final rows = await (db.select(db.privateFoods)
          ..where((f) => f.name.lower().like('%${query.toLowerCase()}%'))
          ..orderBy([(f) => OrderingTerm.asc(f.name)]))
        .get();
    return rows.map(_toResult).toList();
  }

  FoodResult _toResult(PrivateFood row) => FoodResult(
        name: row.name,
        barcode: row.barcode,
        kcalPer100g: row.kcalPer100g,
        proteinPer100g: row.proteinPer100g,
        fatPer100g: row.fatPer100g,
        carbsPer100g: row.carbsPer100g,
        existingPrivateFoodId: row.id,
      );
}
