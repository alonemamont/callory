import 'package:flutter_test/flutter_test.dart';
import 'package:callory/domain/bmr_calculator.dart';

void main() {
  test('male, moderate activity, maintain: matches Mifflin-St Jeor by hand', () {
    // BMR = 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
    // TDEE = 1780 * 1.55 = 2759
    // maintain adjustment = 0% => kcal = 2759
    const input = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
    );

    final result = calculateGoals(input);

    expect(result.kcal, closeTo(2759, 0.5));
    expect(result.proteinG, closeTo(2759 * 0.30 / 4, 0.1));
    expect(result.fatG, closeTo(2759 * 0.30 / 9, 0.1));
    expect(result.carbsG, closeTo(2759 * 0.40 / 4, 0.1));
  });

  test('female, sedentary, lose: applies -20% adjustment', () {
    // BMR = 10*60 + 6.25*165 - 5*25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
    // TDEE = 1345.25 * 1.2 = 1614.3
    // lose adjustment = -20% => kcal = 1291.44
    const input = BmrInput(
      sex: Sex.female,
      age: 25,
      weightKg: 60,
      heightCm: 165,
      activityLevel: ActivityLevel.sedentary,
      goalType: GoalType.lose,
    );

    final result = calculateGoals(input);

    expect(result.kcal, closeTo(1291.44, 0.5));
  });

  test('gain applies +15% adjustment', () {
    const maintainInput = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
    );
    const gainInput = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.gain,
    );

    final maintainKcal = calculateGoals(maintainInput).kcal;
    final gainKcal = calculateGoals(gainInput).kcal;

    expect(gainKcal, closeTo(maintainKcal * 1.15, 0.5));
  });
}
