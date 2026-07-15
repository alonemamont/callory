import 'package:callory/data/open_food_facts_source.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/add_food/add_food_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFoodSource extends OpenFoodFactsSource {
  _FakeFoodSource({this.searchResults = const [], this.barcodeResult});

  final List<FoodResult> searchResults;
  final FoodResult? barcodeResult;

  @override
  Future<List<FoodResult>> searchByName(String query) async => searchResults;

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async => barcodeResult;
}

class _DialogLauncher extends ConsumerWidget {
  const _DialogLauncher({required this.initial, this.barcode});

  final FoodResult initial;
  final String? barcode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showEditableFoodDialog(
            context: context,
            ref: ref,
            initial: initial,
            barcode: barcode,
          ),
          child: const Text('Open dialog'),
        ),
      ),
    );
  }
}

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpDialogHost(
    WidgetTester tester, {
    required FoodResult initial,
    String? barcode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: MaterialApp(
          home: _DialogLauncher(initial: initial, barcode: barcode),
        ),
      ),
    );
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
  }

  Future<void> pumpAddFoodScreen(
    WidgetTester tester, {
    required AppDatabase db,
    OpenFoodFactsSource? externalSource,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          if (externalSource != null)
            openFoodFactsSourceProvider.overrideWithValue(externalSource),
        ],
        child: const MaterialApp(home: AddFoodScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<int> seedPrivateFood(
    AppDatabase db, {
    required String name,
    String? barcode,
    required bool isFavorite,
  }) {
    return db.into(db.privateFoods).insert(
          PrivateFoodsCompanion.insert(
            name: name,
            barcode: Value(barcode),
            kcalPer100g: 100,
            proteinPer100g: 1,
            fatPer100g: 1,
            carbsPer100g: 1,
            source: FoodSourceType.manual,
            isFavorite: Value(isFavorite),
            createdAt: DateTime(2026, 1, 1),
          ),
        );
  }

  Future<int> seedUsedFood(
    AppDatabase db, {
    required String name,
    required bool isFavorite,
  }) async {
    final foodId = await seedPrivateFood(
      db,
      name: name,
      isFavorite: isFavorite,
    );
    final mealId = await db.into(db.meals).insert(
          MealsCompanion.insert(dayDate: DateTime(2026, 7, 15), mealNumber: 1),
        );
    await db.into(db.diaryEntries).insert(
          DiaryEntriesCompanion.insert(
            mealId: mealId,
            privateFoodId: Value(foodId),
            foodNameSnapshot: name,
            grams: 100,
            kcalSnapshot: 100,
            proteinSnapshot: 1,
            fatSnapshot: 1,
            carbsSnapshot: 1,
            occurredAt: DateTime(2026, 7, 15, 12, 0),
            createdAt: DateTime(2026, 7, 15, 12, 0),
            entryDate: DateTime(2026, 7, 15),
          ),
        );
    return foodId;
  }

  testWidgets('manual save can create a favorite product and one diary entry', (tester) async {
    await pumpDialogHost(
      tester,
      initial: const FoodResult(
        name: '',
        kcalPer100g: 0,
        proteinPer100g: 0,
        fatPer100g: 0,
        carbsPer100g: 0,
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Manual Favorite',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Kcal / 100g'),
      '250',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Protein / 100g'),
      '10',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Fat / 100g'), '5');
    await tester.enterText(
      find.widgetWithText(TextField, 'Carbs / 100g'),
      '30',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final foods = await db.select(db.privateFoods).get();
    final entries = await db.select(db.diaryEntries).get();
    expect(foods.single.isFavorite, true);
    expect(entries, hasLength(1));
  });

  testWidgets('cancel creates nothing', (tester) async {
    await pumpDialogHost(
      tester,
      initial: const FoodResult(
        name: '',
        kcalPer100g: 0,
        proteinPer100g: 0,
        fatPer100g: 0,
        carbsPer100g: 0,
      ),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await db.select(db.privateFoods).get(), isEmpty);
    expect(await db.select(db.diaryEntries).get(), isEmpty);
  });

  testWidgets('saving a local product updates it instead of creating a duplicate row', (tester) async {
    final id = await db.into(db.privateFoods).insert(
          PrivateFoodsCompanion.insert(
            name: 'Existing Food',
            kcalPer100g: 100,
            proteinPer100g: 1,
            fatPer100g: 1,
            carbsPer100g: 1,
            source: FoodSourceType.manual,
            createdAt: DateTime(2026, 1, 1),
          ),
        );

    await pumpDialogHost(
      tester,
      initial: FoodResult(
        name: 'Existing Food',
        kcalPer100g: 100,
        proteinPer100g: 1,
        fatPer100g: 1,
        carbsPer100g: 1,
        existingPrivateFoodId: id,
        isFavorite: false,
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Kcal / 100g'),
      '150',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final foods = await db.select(db.privateFoods).get();
    final entries = await db.select(db.diaryEntries).get();
    expect(foods, hasLength(1));
    expect(foods.single.id, id);
    expect(foods.single.kcalPer100g, 150);
    expect(foods.single.isFavorite, true);
    expect(entries, hasLength(1));
  });
}
