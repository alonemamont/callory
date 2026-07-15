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
    bool isFavorite = false,
  }) {
    return db.into(db.privateFoods).insert(PrivateFoodsCompanion.insert(
          name: name,
          barcode: Value(barcode),
          kcalPer100g: kcalPer100g,
          proteinPer100g: proteinPer100g,
          fatPer100g: fatPer100g,
          carbsPer100g: carbsPer100g,
          source: source,
          isFavorite: Value(isFavorite),
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

  Future<void> setFavorite(int id, bool value) {
    return (db.update(db.privateFoods)..where((f) => f.id.equals(id))).write(
      PrivateFoodsCompanion(isFavorite: Value(value)),
    );
  }

  Future<void> toggleFavorite(int id) async {
    final food = await (db.select(db.privateFoods)
          ..where((f) => f.id.equals(id)))
        .getSingle();
    await setFavorite(id, !food.isFavorite);
  }

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

  Future<List<FoodResult>> getRecentFoods({required bool favoritesOnly}) async {
    final whereFavorite = favoritesOnly ? 'WHERE pf.is_favorite = 1' : '';
    final rows = await db.customSelect(
      '''
      SELECT
        pf.id,
        pf.name,
        pf.barcode,
        pf.kcal_per100g,
        pf.protein_per100g,
        pf.fat_per100g,
        pf.carbs_per100g,
        pf.is_favorite
      FROM private_foods pf
      INNER JOIN (
        SELECT private_food_id, MAX(occurred_at) AS last_used_at
        FROM diary_entries
        WHERE private_food_id IS NOT NULL
        GROUP BY private_food_id
      ) recent ON recent.private_food_id = pf.id
      $whereFavorite
      ORDER BY recent.last_used_at DESC, pf.name ASC, pf.id DESC
      ''',
      readsFrom: {db.privateFoods, db.diaryEntries},
    ).get();

    return rows
        .map(
          (row) => FoodResult(
            name: row.read<String>('name'),
            barcode: row.read<String?>('barcode'),
            kcalPer100g: row.read<double>('kcal_per100g'),
            proteinPer100g: row.read<double>('protein_per100g'),
            fatPer100g: row.read<double>('fat_per100g'),
            carbsPer100g: row.read<double>('carbs_per100g'),
            existingPrivateFoodId: row.read<int>('id'),
            isFavorite: row.read<bool>('is_favorite'),
          ),
        )
        .toList();
  }

  FoodResult _toResult(PrivateFood row) => FoodResult(
        name: row.name,
        barcode: row.barcode,
        kcalPer100g: row.kcalPer100g,
        proteinPer100g: row.proteinPer100g,
        fatPer100g: row.fatPer100g,
        carbsPer100g: row.carbsPer100g,
        existingPrivateFoodId: row.id,
        isFavorite: row.isFavorite,
      );
}
