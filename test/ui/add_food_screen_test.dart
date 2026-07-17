import 'package:callory/data/food_lookup_service.dart';
import 'package:callory/data/food_repository.dart';
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
import '../test_helpers.dart';

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
        const FoodResult(
          name: 'Slow Result',
          kcalPer100g: 1,
          proteinPer100g: 1,
          fatPer100g: 1,
          carbsPer100g: 1,
        ),
      ];
    }
    return [
      const FoodResult(
        name: 'Fast Result',
        kcalPer100g: 2,
        proteinPer100g: 2,
        fatPer100g: 2,
        carbsPer100g: 2,
      ),
    ];
  }

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async => null;
}

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
        child: wrapWithLocalizations(
          _DialogLauncher(initial: initial, barcode: barcode),
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
    FoodLookupService? foodLookupService,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          if (externalSource != null)
            openFoodFactsSourceProvider.overrideWithValue(externalSource),
          if (foodLookupService != null)
            foodLookupServiceProvider.overrideWithValue(foodLookupService),
        ],
        child: wrapWithLocalizations(const AddFoodScreen()),
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
    return db
        .into(db.privateFoods)
        .insert(
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
    final mealId = await db
        .into(db.meals)
        .insert(
          MealsCompanion.insert(dayDate: DateTime(2026, 7, 15), mealNumber: 1),
        );
    await db
        .into(db.diaryEntries)
        .insert(
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

  testWidgets(
    'editing an existing private food and re-saving updates the stored macros',
    (tester) async {
      final foodRepo = FoodRepository(db);
      final existingId = await foodRepo.insertFood(
        name: 'My Yogurt',
        kcalPer100g: 90,
        proteinPer100g: 10,
        fatPer100g: 4,
        carbsPer100g: 4,
        source: FoodSourceType.manual,
      );

      await pumpAddFoodScreen(
        tester,
        db: db,
        foodLookupService: FoodLookupService(foodRepo, _EmptySource()),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Search foods'),
        'yogurt',
      );
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
    },
  );

  testWidgets(
    'a stale slow search response does not overwrite a newer fast search',
    (tester) async {
      final source = _SlowThenFastSource();

      await pumpAddFoodScreen(
        tester,
        db: db,
        foodLookupService: FoodLookupService(_EmptySource(), source),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      final searchField = find.widgetWithText(TextField, 'Search foods');

      await tester.enterText(searchField, 'slow-query');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 20));

      await tester.enterText(searchField, 'fast-query');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.textContaining('Fast Result'), findsOneWidget);
      expect(find.textContaining('Slow Result'), findsNothing);
    },
  );

  testWidgets(
    'local results render immediately while the remote search is still pending',
    (tester) async {
      await seedPrivateFood(
        db,
        name: 'Slow-Query Local Food',
        isFavorite: false,
      );

      await pumpAddFoodScreen(
        tester,
        db: db,
        foodLookupService: FoodLookupService(
          FoodRepository(db),
          _SlowThenFastSource(),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      final searchField = find.widgetWithText(TextField, 'Search foods');
      await tester.enterText(searchField, 'slow-query');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.textContaining('Slow-Query Local Food'), findsOneWidget);
      expect(find.textContaining('Slow Result'), findsNothing);

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.textContaining('Slow-Query Local Food'), findsOneWidget);
      expect(find.textContaining('Slow Result'), findsOneWidget);
    },
  );

  testWidgets('manual save can create a favorite product and one diary entry', (
    tester,
  ) async {
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

  testWidgets(
    'saving a local product updates it instead of creating a duplicate row',
    (tester) async {
      final id = await db
          .into(db.privateFoods)
          .insert(
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
    },
  );

  testWidgets(
    'initial tab is Search, and tab order is Recent Search Barcode Manual',
    (tester) async {
      await pumpAddFoodScreen(tester, db: db);

      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Barcode'), findsOneWidget);
      expect(find.text('Manual'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Search foods'), findsOneWidget);
    },
  );

  testWidgets('empty recent state renders correctly', (tester) async {
    await pumpAddFoodScreen(tester, db: db);
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();
    expect(find.text('No recent foods yet'), findsOneWidget);
  });

  testWidgets('favorites-only empty state renders correctly', (tester) async {
    await seedUsedFood(db, name: 'Used Non Favorite', isFavorite: false);
    await pumpAddFoodScreen(tester, db: db);
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('No favorite recent foods yet'), findsOneWidget);
  });

  testWidgets('recent favorite toggle updates the row immediately', (
    tester,
  ) async {
    final id = await seedUsedFood(db, name: 'Recent Oats', isFavorite: false);
    await pumpAddFoodScreen(tester, db: db);
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.star_border).last);
    await tester.pumpAndSettle();

    final foods = await db.select(db.privateFoods).get();
    expect(foods.singleWhere((f) => f.id == id).isFavorite, true);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('tapping a recent row opens the grams-only add-to-meal dialog', (
    tester,
  ) async {
    await seedUsedFood(db, name: 'Recent Rice', isFavorite: true);
    await pumpAddFoodScreen(tester, db: db);
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recent Rice'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Grams eaten'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Kcal / 100g'), findsNothing);
  });

  testWidgets('local search result favorite toggle does not open dialog', (
    tester,
  ) async {
    await seedPrivateFood(
      db,
      name: 'Local Yogurt',
      barcode: '111',
      isFavorite: false,
    );
    await pumpAddFoodScreen(tester, db: db);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search foods'),
      'Yogurt',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.star_border).last);
    await tester.pumpAndSettle();

    expect(find.text('Food details'), findsNothing);
    expect((await db.select(db.privateFoods).get()).single.isFavorite, true);
  });

  testWidgets(
    'external search favorite creates one local row and no diary entry',
    (tester) async {
      await pumpAddFoodScreen(
        tester,
        db: db,
        externalSource: _FakeFoodSource(
          searchResults: const [
            FoodResult(
              name: 'External Bar',
              barcode: '999',
              kcalPer100g: 200,
              proteinPer100g: 20,
              fatPer100g: 8,
              carbsPer100g: 15,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Search foods'),
        'Bar',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.star_border));
      await tester.pumpAndSettle();

      final foods = await db.select(db.privateFoods).get();
      final entries = await db.select(db.diaryEntries).get();
      expect(foods, hasLength(1));
      expect(foods.single.barcode, '999');
      expect(foods.single.isFavorite, true);
      expect(entries, isEmpty);
    },
  );

  testWidgets(
    'favoriting an external result with an existing local barcode updates instead of duplicating',
    (tester) async {
      final existingId = await seedPrivateFood(
        db,
        name: 'Local Bar',
        barcode: '222',
        isFavorite: false,
      );
      await pumpAddFoodScreen(
        tester,
        db: db,
        externalSource: _FakeFoodSource(
          searchResults: const [
            FoodResult(
              name: 'External Bar',
              barcode: '222',
              kcalPer100g: 210,
              proteinPer100g: 21,
              fatPer100g: 9,
              carbsPer100g: 16,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Search foods'),
        'Bar',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.star_border).last);
      await tester.pumpAndSettle();

      final foods = await db.select(db.privateFoods).get();
      expect(foods, hasLength(1));
      expect(foods.single.id, existingId);
      expect(foods.single.isFavorite, true);
    },
  );

  testWidgets(
    'search shows canonical local favorite state for an external barcode match',
    (tester) async {
      await seedPrivateFood(
        db,
        name: 'Older Duplicate',
        barcode: '222',
        isFavorite: false,
      );
      await seedPrivateFood(
        db,
        name: 'Local Match',
        barcode: '222',
        isFavorite: true,
      );
      await pumpAddFoodScreen(
        tester,
        db: db,
        externalSource: _FakeFoodSource(
          searchResults: const [
            FoodResult(
              name: 'External Match',
              barcode: '222',
              kcalPer100g: 210,
              proteinPer100g: 21,
              fatPer100g: 9,
              carbsPer100g: 16,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Search foods'),
        'Match',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.textContaining('(in your foods)'), findsOneWidget);
    },
  );

  testWidgets(
    'typing without submitting triggers a debounced search after 1 second',
    (tester) async {
      await pumpAddFoodScreen(
        tester,
        db: db,
        externalSource: _FakeFoodSource(
          searchResults: const [
            FoodResult(
              name: 'Debounced Result',
              kcalPer100g: 3,
              proteinPer100g: 3,
              fatPer100g: 3,
              carbsPer100g: 3,
            ),
          ],
        ),
      );

      final searchField = find.widgetWithText(TextField, 'Search foods');
      await tester.enterText(searchField, 'd');
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Debounced Result'), findsNothing);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.textContaining('Debounced Result'), findsOneWidget);
    },
  );

  testWidgets(
    'typing again resets the 1 second debounce timer',
    (tester) async {
      await pumpAddFoodScreen(
        tester,
        db: db,
        externalSource: _FakeFoodSource(
          searchResults: const [
            FoodResult(
              name: 'Debounced Result',
              kcalPer100g: 3,
              proteinPer100g: 3,
              fatPer100g: 3,
              carbsPer100g: 3,
            ),
          ],
        ),
      );

      final searchField = find.widgetWithText(TextField, 'Search foods');
      await tester.enterText(searchField, 'd');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.enterText(searchField, 'de');
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.textContaining('Debounced Result'), findsNothing);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.textContaining('Debounced Result'), findsOneWidget);
    },
  );

  testWidgets(
    'saving an external dialog result reuses an existing local barcode row',
    (tester) async {
      final existingId = await seedPrivateFood(
        db,
        name: 'Local Cereal',
        barcode: '333',
        isFavorite: false,
      );
      await pumpDialogHost(
        tester,
        initial: const FoodResult(
          name: 'External Cereal',
          kcalPer100g: 240,
          proteinPer100g: 12,
          fatPer100g: 6,
          carbsPer100g: 30,
        ),
        barcode: '333',
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Grams eaten'),
        '150',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final foods = await db.select(db.privateFoods).get();
      final entries = await db.select(db.diaryEntries).get();
      expect(foods, hasLength(1));
      expect(foods.single.id, existingId);
      expect(foods.single.barcode, '333');
      expect(foods.single.name, 'External Cereal');
      expect(entries, hasLength(1));
      expect(entries.single.privateFoodId, existingId);
    },
  );

  testWidgets(
    'saving an external dialog result with duplicate local barcodes reuses the canonical favorite row',
    (tester) async {
      await seedPrivateFood(
        db,
        name: 'First Duplicate',
        barcode: '444',
        isFavorite: false,
      );
      final favoriteId = await seedPrivateFood(
        db,
        name: 'Second Duplicate',
        barcode: '444',
        isFavorite: true,
      );
      await pumpDialogHost(
        tester,
        initial: const FoodResult(
          name: 'External Duplicate',
          kcalPer100g: 260,
          proteinPer100g: 14,
          fatPer100g: 7,
          carbsPer100g: 31,
        ),
        barcode: '444',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final foods = await db.select(db.privateFoods).get()
        ..sort((a, b) => a.id.compareTo(b.id));
      final entries = await db.select(db.diaryEntries).get();
      expect(foods, hasLength(2));
      expect(
        foods.singleWhere((food) => food.id == favoriteId).name,
        'External Duplicate',
      );
      expect(entries, hasLength(1));
      expect(entries.single.privateFoodId, favoriteId);
    },
  );
}
