import 'package:flutter_test/flutter_test.dart';
import 'package:callory/domain/entry_rescale.dart';

void main() {
  test('scales snapshot proportionally to the new gram amount', () {
    const original = NutrientSnapshot(kcal: 200, protein: 10, fat: 5, carbs: 20);

    final result = rescaleSnapshot(original: original, oldGrams: 100, newGrams: 150);

    expect(result.kcal, closeTo(300, 0.001));
    expect(result.protein, closeTo(15, 0.001));
    expect(result.fat, closeTo(7.5, 0.001));
    expect(result.carbs, closeTo(30, 0.001));
  });

  test('scaling down halves the values', () {
    const original = NutrientSnapshot(kcal: 200, protein: 10, fat: 5, carbs: 20);

    final result = rescaleSnapshot(original: original, oldGrams: 100, newGrams: 50);

    expect(result.kcal, closeTo(100, 0.001));
    expect(result.protein, closeTo(5, 0.001));
  });

  test('throws if old grams is zero or negative', () {
    const original = NutrientSnapshot(kcal: 200, protein: 10, fat: 5, carbs: 20);

    expect(
      () => rescaleSnapshot(original: original, oldGrams: 0, newGrams: 50),
      throwsA(isA<AssertionError>()),
    );
  });
}
