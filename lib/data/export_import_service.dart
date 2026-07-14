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

    await db.transaction(() async {
      await db.delete(db.diaryEntries).go();
      await db.delete(db.meals).go();
      await db.delete(db.privateFoods).go();
      await db.delete(db.goals).go();

      for (final row in (json['privateFoods'] as List)) {
        final food = PrivateFood.fromJson(row as Map<String, dynamic>);
        await db.into(db.privateFoods).insert(food.toCompanion(true));
      }
      for (final row in (json['meals'] as List)) {
        final meal = Meal.fromJson(row as Map<String, dynamic>);
        await db.into(db.meals).insert(meal.toCompanion(true));
      }
      for (final row in (json['diaryEntries'] as List)) {
        final entry = DiaryEntry.fromJson(row as Map<String, dynamic>);
        await db.into(db.diaryEntries).insert(entry.toCompanion(true));
      }
      for (final row in (json['goals'] as List)) {
        final goal = Goal.fromJson(row as Map<String, dynamic>);
        await db.into(db.goals).insert(goal.toCompanion(true));
      }
    });
  }
}
