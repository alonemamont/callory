import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/widgets.dart';
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

  test('localeProvider defaults to null (follow system) when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ]);
    addTearDown(container.dispose);

    expect(container.read(localeProvider), isNull);
  });

  test('localeProvider reads a previously stored locale code on startup', () async {
    SharedPreferences.setMockInitialValues({'locale_code': 'ru'});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ]);
    addTearDown(container.dispose);

    expect(container.read(localeProvider), const Locale('ru'));
  });

  test('setLocale updates state and writes through to SettingsService', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);

    final container = ProviderContainer(overrides: [
      settingsServiceProvider.overrideWithValue(settingsService),
    ]);
    addTearDown(container.dispose);

    await container.read(localeProvider.notifier).setLocale(const Locale('ru'));

    expect(container.read(localeProvider), const Locale('ru'));
    expect(settingsService.localeCode, 'ru');
  });
}
