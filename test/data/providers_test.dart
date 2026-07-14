import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod/riverpod.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/data/food_repository.dart';
import 'package:callory/data/diary_repository.dart';
import 'package:callory/data/goals_repository.dart';
import 'package:callory/data/settings_service.dart';

void main() {
  test('repository providers resolve to the right types and share one database', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ]);
    addTearDown(container.dispose);

    expect(container.read(foodRepositoryProvider), isA<FoodRepository>());
    expect(container.read(diaryRepositoryProvider), isA<DiaryRepository>());
    expect(container.read(goalsRepositoryProvider), isA<GoalsRepository>());

    final foodRepo = container.read(foodRepositoryProvider);
    final diaryRepo = container.read(diaryRepositoryProvider);
    expect(foodRepo.db, same(diaryRepo.db));
  });

  test('selectedDayProvider defaults to today at midnight', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final now = DateTime.now();
    final selected = container.read(selectedDayProvider);

    expect(selected.year, now.year);
    expect(selected.month, now.month);
    expect(selected.day, now.day);
    expect(selected.hour, 0);
  });
}
