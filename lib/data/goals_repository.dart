import 'package:drift/drift.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/bmr_calculator.dart';

class GoalsRepository {
  final AppDatabase db;
  GoalsRepository(this.db);

  Future<Goal?> getGoals() => (db.select(db.goals)..limit(1)).getSingleOrNull();

  Future<void> setManualGoals({
    required double dailyKcal,
    required double dailyProtein,
    required double dailyFat,
    required double dailyCarbs,
  }) async {
    await db.transaction(() async {
      await db.delete(db.goals).go();
      await db.into(db.goals).insert(GoalsCompanion.insert(
            dailyKcal: dailyKcal,
            dailyProtein: dailyProtein,
            dailyFat: dailyFat,
            dailyCarbs: dailyCarbs,
            mode: GoalsMode.manual,
          ));
    });
  }

  Future<void> setCalculatedGoals(BmrInput input) async {
    final result = calculateGoals(input);
    await db.transaction(() async {
      await db.delete(db.goals).go();
      await db.into(db.goals).insert(GoalsCompanion.insert(
            dailyKcal: result.kcal,
            dailyProtein: result.proteinG,
            dailyFat: result.fatG,
            dailyCarbs: result.carbsG,
            mode: GoalsMode.calculated,
            age: Value(input.age),
            weightKg: Value(input.weightKg),
            heightCm: Value(input.heightCm),
            sex: Value(input.sex.name),
            activityLevel: Value(input.activityLevel.name),
            goalType: Value(input.goalType.name),
          ));
    });
  }
}
