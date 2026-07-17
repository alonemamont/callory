import 'package:callory/data/food_repository.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/add_food/manual_tab.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/data/settings_service.dart';
import '../test_helpers.dart';

class _AddProductLauncher extends ConsumerWidget {
  const _AddProductLauncher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showAddProductDialog(context: context, ref: ref),
          child: const Text('Open add product dialog'),
        ),
      ),
    );
  }
}

class _LogExistingLauncher extends ConsumerWidget {
  const _LogExistingLauncher({required this.food});

  final FoodResult food;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showLogExistingFoodDialog(context: context, ref: ref, food: food),
          child: const Text('Open log dialog'),
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

  Future<void> pumpLauncher(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: wrapWithLocalizations(const _AddProductLauncher()),
      ),
    );
    await tester.tap(find.text('Open add product dialog'));
    await tester.pumpAndSettle();
  }

  testWidgets('filling the form creates a product with no diary entry', (tester) async {
    await pumpLauncher(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Oatmeal');
    await tester.enterText(find.widgetWithText(TextField, 'Kcal / 100g'), '380');
    await tester.enterText(find.widgetWithText(TextField, 'Protein / 100g'), '13');
    await tester.enterText(find.widgetWithText(TextField, 'Fat / 100g'), '7');
    await tester.enterText(find.widgetWithText(TextField, 'Carbs / 100g'), '67');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final foods = await db.select(db.privateFoods).get();
    final entries = await db.select(db.diaryEntries).get();
    expect(foods, hasLength(1));
    expect(foods.single.name, 'Oatmeal');
    expect(foods.single.kcalPer100g, 380);
    expect(entries, isEmpty);
  });

  testWidgets('invalid nutrient value shows an error and creates nothing', (tester) async {
    await pumpLauncher(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Bad Food');
    await tester.enterText(find.widgetWithText(TextField, 'Kcal / 100g'), '-5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nutrient values must be non-negative numbers'), findsOneWidget);
    expect(await db.select(db.privateFoods).get(), isEmpty);
  });

  testWidgets('log-existing dialog shows no editable nutrition fields, only grams', (tester) async {
    final foodRepo = FoodRepository(db);
    final id = await foodRepo.insertFood(
      name: 'Known Rice',
      kcalPer100g: 130,
      proteinPer100g: 3,
      fatPer100g: 0,
      carbsPer100g: 28,
      source: FoodSourceType.manual,
    );

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: wrapWithLocalizations(
          _LogExistingLauncher(
            food: FoodResult(
              name: 'Known Rice',
              kcalPer100g: 130,
              proteinPer100g: 3,
              fatPer100g: 0,
              carbsPer100g: 28,
              existingPrivateFoodId: id,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open log dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Known Rice'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Kcal / 100g'), findsNothing);
    expect(find.widgetWithText(TextField, 'Protein / 100g'), findsNothing);
    expect(find.widgetWithText(TextField, 'Grams eaten'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Grams eaten'), '200');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final entries = await db.select(db.diaryEntries).get();
    expect(entries, hasLength(1));
    expect(entries.single.privateFoodId, id);
    expect(entries.single.grams, 200);
    expect(entries.single.kcalSnapshot, 260);
    expect(entries.single.carbsSnapshot, 56);
  });

  testWidgets('log-existing dialog rejects a non-positive grams value', (tester) async {
    final foodRepo = FoodRepository(db);
    final id = await foodRepo.insertFood(
      name: 'Known Bread',
      kcalPer100g: 265,
      proteinPer100g: 9,
      fatPer100g: 3,
      carbsPer100g: 49,
      source: FoodSourceType.manual,
    );

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: wrapWithLocalizations(
          _LogExistingLauncher(
            food: FoodResult(
              name: 'Known Bread',
              kcalPer100g: 265,
              proteinPer100g: 9,
              fatPer100g: 3,
              carbsPer100g: 49,
              existingPrivateFoodId: id,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open log dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Grams eaten'), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Grams eaten must be a positive number'), findsOneWidget);
    expect(await db.select(db.diaryEntries).get(), isEmpty);
  });
}
