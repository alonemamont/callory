import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/data/food_repository.dart';
import 'package:callory/data/food_lookup_service.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/add_food/add_food_screen.dart';

class _EmptySource implements FoodSource {
  @override
  Future<List<FoodResult>> searchByName(String query) async => [];

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async => null;
}

class _SlowThenFastSource implements FoodSource {
  @override
  Future<List<FoodResult>> searchByName(String query) async {
    if (query == 'slow-query') {
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        const FoodResult(name: 'Slow Result', kcalPer100g: 1, proteinPer100g: 1, fatPer100g: 1, carbsPer100g: 1),
      ];
    }
    return [
      const FoodResult(name: 'Fast Result', kcalPer100g: 2, proteinPer100g: 2, fatPer100g: 2, carbsPer100g: 2),
    ];
  }

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async => null;
}

void main() {
  testWidgets('editing an existing private food and re-saving updates the stored macros', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final foodRepo = FoodRepository(db);
    final existingId = await foodRepo.insertFood(
      name: 'My Yogurt',
      kcalPer100g: 90,
      proteinPer100g: 10,
      fatPer100g: 4,
      carbsPer100g: 4,
      source: FoodSourceType.manual,
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        foodLookupServiceProvider.overrideWithValue(FoodLookupService(foodRepo, _EmptySource())),
      ],
      child: const MaterialApp(home: AddFoodScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'yogurt');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('My Yogurt'));
    await tester.pumpAndSettle();

    final kcalField = find.widgetWithText(TextField, 'Kcal / 100g');
    await tester.enterText(kcalField, '500');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final rows = await db.select(db.privateFoods).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, existingId);
    expect(rows.single.kcalPer100g, 500);

    await db.close();
  });

  testWidgets('a stale slow search response does not overwrite a newer fast search', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final source = _SlowThenFastSource();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        foodLookupServiceProvider.overrideWithValue(FoodLookupService(_EmptySource(), source)),
      ],
      child: const MaterialApp(home: AddFoodScreen()),
    ));
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField).first;

    await tester.enterText(searchField, 'slow-query');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 20)); // slow request in flight, not resolved yet

    await tester.enterText(searchField, 'fast-query');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle(const Duration(milliseconds: 300)); // let both requests resolve

    expect(find.textContaining('Fast Result'), findsOneWidget);
    expect(find.textContaining('Slow Result'), findsNothing);

    await db.close();
  });
}
