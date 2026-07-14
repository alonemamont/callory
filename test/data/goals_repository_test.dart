import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/goals_repository.dart';
import 'package:callory/domain/bmr_calculator.dart';

void main() {
  late AppDatabase db;
  late GoalsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GoalsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('setManualGoals stores exactly the provided numbers in manual mode', () async {
    await repo.setManualGoals(
      dailyKcal: 2200,
      dailyProtein: 150,
      dailyFat: 70,
      dailyCarbs: 220,
    );

    final goals = await repo.getGoals();
    expect(goals, isNotNull);
    expect(goals!.mode, GoalsMode.manual);
    expect(goals.dailyKcal, 2200);
  });

  test('setCalculatedGoals derives numbers from BMR input and stores calculated mode', () async {
    const input = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
    );

    await repo.setCalculatedGoals(input);

    final goals = await repo.getGoals();
    expect(goals!.mode, GoalsMode.calculated);
    expect(goals.dailyKcal, closeTo(2759, 0.5));
    expect(goals.age, 30);
  });

  test('setting new goals replaces the previous single record', () async {
    await repo.setManualGoals(
      dailyKcal: 2000,
      dailyProtein: 100,
      dailyFat: 60,
      dailyCarbs: 200,
    );
    await repo.setManualGoals(
      dailyKcal: 2500,
      dailyProtein: 130,
      dailyFat: 80,
      dailyCarbs: 260,
    );

    final goals = await repo.getGoals();
    expect(goals!.dailyKcal, 2500);
  });
}
