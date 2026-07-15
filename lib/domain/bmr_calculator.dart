enum Sex { male, female }

enum ActivityLevel { sedentary, light, moderate, high }

enum GoalType { lose, maintain, gain }

class BmrInput {
  final Sex sex;
  final int age;
  final double weightKg;
  final double heightCm;
  final ActivityLevel activityLevel;
  final GoalType goalType;

  const BmrInput({
    required this.sex,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    required this.goalType,
  });
}

class MacroGoals {
  final double kcal;
  final double proteinG;
  final double fatG;
  final double carbsG;

  const MacroGoals({
    required this.kcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });
}

const _activityMultipliers = {
  ActivityLevel.sedentary: 1.2,
  ActivityLevel.light: 1.375,
  ActivityLevel.moderate: 1.55,
  ActivityLevel.high: 1.725,
};

const _goalAdjustments = {
  GoalType.lose: -0.20,
  GoalType.maintain: 0.0,
  GoalType.gain: 0.15,
};

MacroGoals calculateGoals(BmrInput input) {
  final bmr = input.sex == Sex.male
      ? 10 * input.weightKg + 6.25 * input.heightCm - 5 * input.age + 5
      : 10 * input.weightKg + 6.25 * input.heightCm - 5 * input.age - 161;

  final tdee = bmr * _activityMultipliers[input.activityLevel]!;
  final kcal = tdee * (1 + _goalAdjustments[input.goalType]!);

  return MacroGoals(
    kcal: kcal,
    proteinG: (kcal * 0.30) / 4,
    fatG: (kcal * 0.30) / 9,
    carbsG: (kcal * 0.40) / 4,
  );
}
