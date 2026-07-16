class NutrientSnapshot {
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;

  const NutrientSnapshot({
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

NutrientSnapshot rescaleSnapshot({
  required NutrientSnapshot original,
  required double oldGrams,
  required double newGrams,
}) {
  if (oldGrams <= 0) {
    throw ArgumentError.value(oldGrams, 'oldGrams', 'must be positive to rescale a snapshot');
  }
  final ratio = newGrams / oldGrams;
  return NutrientSnapshot(
    kcal: original.kcal * ratio,
    protein: original.protein * ratio,
    fat: original.fat * ratio,
    carbs: original.carbs * ratio,
  );
}
