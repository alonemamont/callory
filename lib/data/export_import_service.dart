import 'package:callory/db/database.dart';

class ExportImportService {
  static const formatVersion = 1;

  final AppDatabase db;
  ExportImportService(this.db);

  Future<Map<String, dynamic>> exportToJson() async {
    final foods = await db.select(db.privateFoods).get();
    final meals = await db.select(db.meals).get();
    final entries = await db.select(db.diaryEntries).get();
    final goals = await db.select(db.goals).get();

    return {
      'formatVersion': formatVersion,
      'privateFoods': foods.map((f) => f.toJson()).toList(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'diaryEntries': entries.map((e) => e.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
    };
  }

  Future<void> importFromJson(Map<String, dynamic> json) async {
    if (json['formatVersion'] != formatVersion) {
      throw FormatException(
        'Unsupported export format version: ${json['formatVersion']}',
      );
    }

    final foods = (json['privateFoods'] as List)
        .map((row) {
          final foodJson = Map<String, dynamic>.from(row as Map<String, dynamic>);
          foodJson.putIfAbsent('isFavorite', () => false);
          return PrivateFood.fromJson(foodJson);
        })
        .toList();
    final meals = (json['meals'] as List)
        .map((row) => Meal.fromJson(row as Map<String, dynamic>))
        .toList();
    final entries = (json['diaryEntries'] as List)
        .map((row) => DiaryEntry.fromJson(row as Map<String, dynamic>))
        .toList();
    final goals = (json['goals'] as List)
        .map((row) => Goal.fromJson(row as Map<String, dynamic>))
        .toList();

    for (final entry in entries) {
      final valid = entry.grams > 0 &&
          entry.kcalSnapshot.isFinite &&
          entry.proteinSnapshot.isFinite &&
          entry.fatSnapshot.isFinite &&
          entry.carbsSnapshot.isFinite;
      if (!valid) {
        throw FormatException('Invalid diary entry in import data: id ${entry.id}');
      }
    }
    for (final food in foods) {
      final valid = food.kcalPer100g.isFinite &&
          food.kcalPer100g >= 0 &&
          food.proteinPer100g.isFinite &&
          food.proteinPer100g >= 0 &&
          food.fatPer100g.isFinite &&
          food.fatPer100g >= 0 &&
          food.carbsPer100g.isFinite &&
          food.carbsPer100g >= 0;
      if (!valid) {
        throw FormatException('Invalid private food in import data: id ${food.id}');
      }
    }

    await db.transaction(() async {
      await db.delete(db.diaryEntries).go();
      await db.delete(db.meals).go();
      await db.delete(db.privateFoods).go();
      await db.delete(db.goals).go();

      for (final food in foods) {
        await db.into(db.privateFoods).insert(food.toCompanion(true));
      }
      for (final meal in meals) {
        await db.into(db.meals).insert(meal.toCompanion(true));
      }
      for (final entry in entries) {
        await db.into(db.diaryEntries).insert(entry.toCompanion(true));
      }
      for (final goal in goals) {
        await db.into(db.goals).insert(goal.toCompanion(true));
      }
    });
  }
}
