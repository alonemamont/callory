import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/food_repository.dart';
import 'package:callory/data/diary_repository.dart';
import 'package:callory/data/goals_repository.dart';
import 'package:callory/data/open_food_facts_source.dart';
import 'package:callory/data/food_lookup_service.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/data/export_import_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository(ref.watch(databaseProvider));
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository(ref.watch(databaseProvider));
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository(ref.watch(databaseProvider));
});

final openFoodFactsSourceProvider = Provider<OpenFoodFactsSource>((ref) {
  return OpenFoodFactsSource();
});

final foodLookupServiceProvider = Provider<FoodLookupService>((ref) {
  return FoodLookupService(
    ref.watch(foodRepositoryProvider),
    ref.watch(openFoodFactsSourceProvider),
  );
});

final exportImportServiceProvider = Provider<ExportImportService>((ref) {
  return ExportImportService(ref.watch(databaseProvider));
});

/// Must be overridden at app startup with a real `SharedPreferences`
/// instance (see Task 19) — `SharedPreferences.getInstance()` is async and
/// can't be awaited inside a synchronous provider body.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError(
    'settingsServiceProvider must be overridden at app startup',
  );
});

DateTime _todayAtMidnight() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

final selectedDayProvider = StateProvider<DateTime>((ref) => _todayAtMidnight());
