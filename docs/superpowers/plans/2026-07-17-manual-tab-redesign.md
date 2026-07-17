# Manual tab redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single-button Manual tab in `AddFoodScreen` with: an "Add product" button that only creates a library product (no diary log), a searchable list of every existing product below it, and tapping a list item opens a grams-only dialog (nutrition read-only) that logs today's entry.

**Architecture:** New file `lib/ui/add_food/manual_tab.dart` holds the redesigned `ManualTab` widget plus its two new dialog functions (`showAddProductDialog`, `showLogExistingFoodDialog`). `lib/ui/add_food/add_food_screen.dart` keeps `showEditableFoodDialog` for Recent/Search/Barcode (unchanged behavior), loses its old private `_ManualTab` class, and exposes its diary-logging helper (renamed from `_logEntry` to public `logDiaryEntry`) so the new file can reuse it. One new repository method, `FoodRepository.getAllFoods()`, backs the product list.

**Tech Stack:** Flutter/Dart, `flutter_riverpod`, `drift`, Flutter's built-in `gen-l10n`, `flutter_test` widget tests.

## Global Constraints

- Scope is limited to `lib/data/food_repository.dart`, `lib/l10n/*.arb`, `lib/ui/add_food/add_food_screen.dart`, `lib/ui/add_food/manual_tab.dart` (new), `test/data/food_repository_test.dart`, and `test/ui/manual_tab_test.dart` (new).
- Never hand-edit `lib/l10n/app_localizations*.dart` — generated. After any `.arb` change, run `flutter gen-l10n` before compiling or testing code that references new getters.
- Renaming `_logEntry` → `logDiaryEntry` in Task 3 is a pure rename (same params, same behavior) — the full existing suite in `test/ui/add_food_screen_test.dart` must stay green after it, with no test edits needed.
- Reuse existing loc getters wherever possible: `addFoodKcalPer100g`, `dayEntryMacroSuffix` (already defined for the day screen's macro line — generic enough to reuse here), `addFoodNameLabel/KcalLabel/ProteinLabel/FatLabel/CarbsLabel/FavoriteLabel/GramsEatenLabel/SaveButton/CancelButton/SearchLabel/NutrientError/GramsError`. Only three new keys are needed: `addFoodAddProductButton`, `addFoodAddProductDialogTitle`, `addFoodNoProductsYet`.
- Flutter binary for all commands below: `flutter` (resolved on PATH at `/e/work/flutter/bin/flutter`).

---

### Task 1: `FoodRepository.getAllFoods()`

**Files:**
- Modify: `lib/data/food_repository.dart` (add method after `getRecentFoods`, currently ending line 150)
- Test: `test/data/food_repository_test.dart` (add test after the `getRecentFoods` test, currently ending line 262)

**Interfaces:**
- Produces: `Future<List<FoodResult>> getAllFoods()` on `FoodRepository` — every `private_foods` row, ordered by `name` ascending. Consumed by Task 6 (`ManualTab`).

- [ ] **Step 1: Write the failing test**

In `test/data/food_repository_test.dart`, add before the final closing `}` of `main()`:

```dart
  test('getAllFoods returns every private food alphabetically by name, regardless of diary usage', () async {
    await repo.insertFood(
      name: 'Zucchini',
      kcalPer100g: 20,
      proteinPer100g: 1,
      fatPer100g: 0,
      carbsPer100g: 3,
      source: FoodSourceType.manual,
    );
    await repo.insertFood(
      name: 'Apple',
      kcalPer100g: 52,
      proteinPer100g: 0,
      fatPer100g: 0,
      carbsPer100g: 14,
      source: FoodSourceType.manual,
    );

    final all = await repo.getAllFoods();

    expect(all.map((f) => f.name).toList(), ['Apple', 'Zucchini']);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/food_repository_test.dart --plain-name "getAllFoods"`
Expected: FAIL — `Error: The method 'getAllFoods' isn't defined for the class 'FoodRepository'`.

- [ ] **Step 3: Implement the method**

In `lib/data/food_repository.dart`, add after `getRecentFoods` (after the closing `}` currently at line 150, before `void _validateNutrients`):

```dart

  Future<List<FoodResult>> getAllFoods() async {
    final rows = await (db.select(db.privateFoods)
          ..orderBy([(f) => OrderingTerm.asc(f.name)]))
        .get();
    return rows.map(_toResult).toList();
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/food_repository_test.dart`
Expected: PASS — all tests in the file, including the new one.

- [ ] **Step 5: Commit**

```bash
git add lib/data/food_repository.dart test/data/food_repository_test.dart
git commit -m "feat: add FoodRepository.getAllFoods"
```

---

### Task 2: New l10n keys

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_ru.arb`

**Interfaces:**
- Produces: `AppLocalizations.addFoodAddProductButton`, `.addFoodAddProductDialogTitle`, `.addFoodNoProductsYet` getters. Consumed by Task 5 (`showAddProductDialog`) and Task 6 (`ManualTab`).

- [ ] **Step 1: Add the keys to `lib/l10n/app_en.arb`**

Insert after `"addFoodSaveButton": "Save",` (currently line 108):

```json
  "addFoodSaveButton": "Save",
  "addFoodAddProductButton": "Add product",
  "addFoodAddProductDialogTitle": "New product",
  "addFoodNoProductsYet": "No products yet",
```

- [ ] **Step 2: Add the keys to `lib/l10n/app_ru.arb`**

Insert after `"addFoodSaveButton": "Сохранить",` (currently line 83):

```json
  "addFoodSaveButton": "Сохранить",
  "addFoodAddProductButton": "Добавить продукт",
  "addFoodAddProductDialogTitle": "Новый продукт",
  "addFoodNoProductsYet": "Пока нет продуктов",
```

- [ ] **Step 3: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: exits 0.

Run: `grep -c "addFoodAddProductButton\|addFoodAddProductDialogTitle\|addFoodNoProductsYet" lib/l10n/app_localizations_en.dart`
Expected: `3`.

- [ ] **Step 4: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_ru.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_ru.dart
git commit -m "feat: add l10n keys for manual-tab add-product flow"
```

---

### Task 3: Make the diary-logging helper reusable across files

**Files:**
- Modify: `lib/ui/add_food/add_food_screen.dart:506-515, 534-543, 547-573` (the two call sites of `_logEntry` and its definition)

**Interfaces:**
- Produces: `Future<void> logDiaryEntry(WidgetRef ref, {required int privateFoodId, required String name, required double grams, required double kcalPer100g, required double proteinPer100g, required double fatPer100g, required double carbsPer100g})` — same signature as the old private `_logEntry`, just public. Consumed by Task 5 (`showLogExistingFoodDialog`).

This is a pure rename — no behavior change, no test changes expected.

- [ ] **Step 1: Confirm the current suite is green (baseline)**

Run: `flutter test test/ui/add_food_screen_test.dart`
Expected: PASS — all tests (this is the baseline the rename must not break).

- [ ] **Step 2: Rename the function definition**

In `lib/ui/add_food/add_food_screen.dart`, change:

```dart
Future<void> _logEntry(
  WidgetRef ref, {
```

to:

```dart
Future<void> logDiaryEntry(
  WidgetRef ref, {
```

(the rest of the function body, currently lines 547-573, is unchanged).

- [ ] **Step 3: Update both call sites**

In `lib/ui/add_food/add_food_screen.dart`, inside `showEditableFoodDialog`, change both occurrences of:

```dart
    await _logEntry(
      ref,
```

to:

```dart
    await logDiaryEntry(
      ref,
```

(there are exactly two: one in the `if (privateFoodId != null)` branch around line 506, one after `insertFood` around line 534).

- [ ] **Step 4: Run the suite again to confirm no regression**

Run: `flutter test test/ui/add_food_screen_test.dart`
Expected: PASS — identical result to Step 1.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/add_food/add_food_screen.dart
git commit -m "refactor: expose logDiaryEntry so the manual tab can reuse it"
```

---

### Task 4: `showAddProductDialog`

**Files:**
- Create: `lib/ui/add_food/manual_tab.dart`
- Test: `test/ui/manual_tab_test.dart` (new)

**Interfaces:**
- Consumes: `FoodRepository.insertFood` (existing, unchanged), `AppLocalizations.addFoodAddProductDialogTitle/addFoodNameLabel/addFoodKcalLabel/addFoodProteinLabel/addFoodFatLabel/addFoodCarbsLabel/addFoodFavoriteLabel/addFoodNutrientError/addFoodCancelButton/addFoodSaveButton`, `NumberField` (`lib/ui/widgets/number_field.dart`, unchanged).
- Produces: `Future<bool> showAddProductDialog({required BuildContext context, required WidgetRef ref})` — returns `true` if a product was created. Consumed by Task 6 (`ManualTab`).

- [ ] **Step 1: Write the failing test**

Create `test/ui/manual_tab_test.dart`:

```dart
import 'package:callory/data/food_repository.dart';
import 'package:callory/db/database.dart';
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/ui/manual_tab_test.dart`
Expected: FAIL — `Error: Type 'showAddProductDialog' not found` / `manual_tab.dart` doesn't exist yet.

- [ ] **Step 3: Create `manual_tab.dart` with `showAddProductDialog`**

Create `lib/ui/add_food/manual_tab.dart`:

```dart
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/l10n/app_localizations.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/add_food/add_food_screen.dart' show logDiaryEntry;
import 'package:callory/ui/widgets/number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showAddProductDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final loc = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final kcalController = TextEditingController(text: '0');
  final proteinController = TextEditingController(text: '0');
  final fatController = TextEditingController(text: '0');
  final carbsController = TextEditingController(text: '0');
  var isFavorite = false;
  String? errorText;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(loc.addFoodAddProductDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: loc.addFoodNameLabel),
              ),
              NumberField(controller: kcalController, labelText: loc.addFoodKcalLabel),
              NumberField(controller: proteinController, labelText: loc.addFoodProteinLabel),
              NumberField(controller: fatController, labelText: loc.addFoodFatLabel),
              NumberField(controller: carbsController, labelText: loc.addFoodCarbsLabel),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isFavorite,
                title: Text(loc.addFoodFavoriteLabel),
                onChanged: (value) => setState(() => isFavorite = value ?? false),
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.addFoodCancelButton),
          ),
          TextButton(
            onPressed: () {
              final kcal = double.tryParse(kcalController.text);
              final protein = double.tryParse(proteinController.text);
              final fat = double.tryParse(fatController.text);
              final carbs = double.tryParse(carbsController.text);
              final nutrients = [kcal, protein, fat, carbs];
              if (nutrients.any((v) => v == null || !v.isFinite || v < 0)) {
                setState(() => errorText = loc.addFoodNutrientError);
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(loc.addFoodSaveButton),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return false;

  await ref.read(foodRepositoryProvider).insertFood(
        name: nameController.text,
        barcode: null,
        kcalPer100g: double.parse(kcalController.text),
        proteinPer100g: double.parse(proteinController.text),
        fatPer100g: double.parse(fatController.text),
        carbsPer100g: double.parse(carbsController.text),
        source: FoodSourceType.manual,
        isFavorite: isFavorite,
      );
  return true;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/ui/manual_tab_test.dart`
Expected: PASS — both tests.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/add_food/manual_tab.dart test/ui/manual_tab_test.dart
git commit -m "feat: add showAddProductDialog (create-only, no diary log)"
```

---

### Task 5: `showLogExistingFoodDialog`

**Files:**
- Modify: `lib/ui/add_food/manual_tab.dart` (append the new function)
- Test: `test/ui/manual_tab_test.dart` (append tests)

**Interfaces:**
- Consumes: `logDiaryEntry` (Task 3), `AppLocalizations.addFoodKcalPer100g`, `.dayEntryMacroSuffix` (existing day-screen key, reused for the read-only macro line), `.addFoodGramsEatenLabel/addFoodGramsError/addFoodCancelButton/addFoodSaveButton`.
- Produces: `Future<bool> showLogExistingFoodDialog({required BuildContext context, required WidgetRef ref, required FoodResult food})` — returns `true` if an entry was logged. `food.existingPrivateFoodId` must be non-null (always true for rows coming from `getAllFoods()`). Consumed by Task 6 (`ManualTab`).

- [ ] **Step 1: Write the failing tests**

In `test/ui/manual_tab_test.dart`, add a launcher and tests. First, add this class next to `_AddProductLauncher`:

```dart
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
```

Add the import at the top of the file: `import 'package:callory/domain/food_source.dart';`

Then add these tests before the final closing `}` of `main()`:

```dart
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
    expect(entries.single.kcalSnapshot, 130);
    expect(entries.single.carbsSnapshot, 28);
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/ui/manual_tab_test.dart --plain-name "log-existing"`
Expected: FAIL — `Error: Type 'showLogExistingFoodDialog' not found`.

- [ ] **Step 3: Add `showLogExistingFoodDialog` to `manual_tab.dart`**

Append to `lib/ui/add_food/manual_tab.dart`:

```dart

Future<bool> showLogExistingFoodDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FoodResult food,
}) async {
  final loc = AppLocalizations.of(context)!;
  final gramsController = TextEditingController(text: '100');
  String? errorText;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(food.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.addFoodKcalPer100g(food.kcalPer100g.round())),
            Text(
              '${food.proteinPer100g.round()}/${food.fatPer100g.round()}/'
              '${food.carbsPer100g.round()} ${loc.dayEntryMacroSuffix}',
            ),
            NumberField(controller: gramsController, labelText: loc.addFoodGramsEatenLabel),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.addFoodCancelButton),
          ),
          TextButton(
            onPressed: () {
              final grams = double.tryParse(gramsController.text);
              if (grams == null || !grams.isFinite || grams <= 0) {
                setState(() => errorText = loc.addFoodGramsError);
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(loc.addFoodSaveButton),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return false;

  await logDiaryEntry(
    ref,
    privateFoodId: food.existingPrivateFoodId!,
    name: food.name,
    grams: double.parse(gramsController.text),
    kcalPer100g: food.kcalPer100g,
    proteinPer100g: food.proteinPer100g,
    fatPer100g: food.fatPer100g,
    carbsPer100g: food.carbsPer100g,
  );
  return true;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/ui/manual_tab_test.dart`
Expected: PASS — all 4 tests so far.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/add_food/manual_tab.dart test/ui/manual_tab_test.dart
git commit -m "feat: add showLogExistingFoodDialog (grams-only, read-only nutrition)"
```

---

### Task 6: `ManualTab` widget — search, list, favorite toggle — and wire it in

**Files:**
- Modify: `lib/ui/add_food/manual_tab.dart` (append the `ManualTab` widget)
- Modify: `lib/ui/add_food/add_food_screen.dart:1-8` (imports), `:51-57` (`TabBarView` children), `:349-379` (remove old `_ManualTab`)
- Test: `test/ui/manual_tab_test.dart` (append integration tests)

**Interfaces:**
- Consumes: `FoodRepository.getAllFoods` (Task 1), `FoodRepository.setFavorite` (existing), `showAddProductDialog` (Task 4), `showLogExistingFoodDialog` (Task 5), `AppLocalizations.addFoodAddProductButton/addFoodSearchLabel/addFoodNoProductsYet/addFoodKcalPer100g`.
- Produces: `ManualTab` (public `ConsumerStatefulWidget`, no constructor params) — the widget `add_food_screen.dart`'s `TabBarView` uses in place of the old `_ManualTab`.

- [ ] **Step 1: Write the failing integration tests**

In `test/ui/manual_tab_test.dart`, add this import at the top: `import 'package:callory/ui/add_food/add_food_screen.dart';`

Then add before the final closing `}` of `main()`:

```dart
  Future<void> pumpAddFoodScreen(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: wrapWithLocalizations(const AddFoodScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();
  }

  testWidgets('adding a product shows it in the list below with no diary entry', (tester) async {
    await pumpAddFoodScreen(tester);

    expect(find.text('No products yet'), findsOneWidget);

    await tester.tap(find.text('Add product'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Banana');
    await tester.enterText(find.widgetWithText(TextField, 'Kcal / 100g'), '89');
    await tester.enterText(find.widgetWithText(TextField, 'Protein / 100g'), '1');
    await tester.enterText(find.widgetWithText(TextField, 'Fat / 100g'), '0');
    await tester.enterText(find.widgetWithText(TextField, 'Carbs / 100g'), '23');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Banana'), findsOneWidget);
    expect(await db.select(db.diaryEntries).get(), isEmpty);
  });

  testWidgets('tapping a listed product opens the log-existing dialog and logs an entry', (tester) async {
    final foodRepo = FoodRepository(db);
    await foodRepo.insertFood(
      name: 'Chicken Breast',
      kcalPer100g: 165,
      proteinPer100g: 31,
      fatPer100g: 4,
      carbsPer100g: 0,
      source: FoodSourceType.manual,
    );

    await pumpAddFoodScreen(tester);

    await tester.tap(find.text('Chicken Breast'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Kcal / 100g'), findsNothing);
    await tester.enterText(find.widgetWithText(TextField, 'Grams eaten'), '150');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final entries = await db.select(db.diaryEntries).get();
    expect(entries, hasLength(1));
    expect(entries.single.grams, 150);
  });

  testWidgets('search filters the product list by name', (tester) async {
    final foodRepo = FoodRepository(db);
    await foodRepo.insertFood(
      name: 'Almonds',
      kcalPer100g: 579,
      proteinPer100g: 21,
      fatPer100g: 50,
      carbsPer100g: 22,
      source: FoodSourceType.manual,
    );
    await foodRepo.insertFood(
      name: 'Walnuts',
      kcalPer100g: 654,
      proteinPer100g: 15,
      fatPer100g: 65,
      carbsPer100g: 14,
      source: FoodSourceType.manual,
    );

    await pumpAddFoodScreen(tester);

    expect(find.text('Almonds'), findsOneWidget);
    expect(find.text('Walnuts'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Search foods'), 'wal');
    await tester.pumpAndSettle();

    expect(find.text('Almonds'), findsNothing);
    expect(find.text('Walnuts'), findsOneWidget);
  });

  testWidgets('tapping the star toggles favorite and persists across refresh', (tester) async {
    final foodRepo = FoodRepository(db);
    await foodRepo.insertFood(
      name: 'Greek Yogurt',
      kcalPer100g: 59,
      proteinPer100g: 10,
      fatPer100g: 0,
      carbsPer100g: 4,
      source: FoodSourceType.manual,
    );

    await pumpAddFoodScreen(tester);

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star), findsOneWidget);
    final foods = await db.select(db.privateFoods).get();
    expect(foods.single.isFavorite, true);
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/ui/manual_tab_test.dart --plain-name "list"`
Expected: FAIL — the Manual tab still shows the old single "Add food manually" button, so `find.text('No products yet')` etc. find nothing (`ManualTab` doesn't exist yet / old `_ManualTab` still wired in).

- [ ] **Step 3: Add the `ManualTab` widget to `manual_tab.dart`**

Append to `lib/ui/add_food/manual_tab.dart`:

```dart

class ManualTab extends ConsumerStatefulWidget {
  const ManualTab({super.key});

  @override
  ConsumerState<ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends ConsumerState<ManualTab> {
  late Future<List<FoodResult>> _allFoods;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _allFoods = ref.read(foodRepositoryProvider).getAllFoods();
  }

  void _refresh() {
    setState(() {
      _allFoods = ref.read(foodRepositoryProvider).getAllFoods();
    });
  }

  Future<void> _toggleFavorite(FoodResult food) async {
    await ref
        .read(foodRepositoryProvider)
        .setFavorite(food.existingPrivateFoodId!, !food.isFavorite);
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () async {
              final saved = await showAddProductDialog(context: context, ref: ref);
              if (saved && mounted) _refresh();
            },
            child: Text(loc.addFoodAddProductButton),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            decoration: InputDecoration(labelText: loc.addFoodSearchLabel),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<FoodResult>>(
            future: _allFoods,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snapshot.data ?? const <FoodResult>[];
              final filtered = _query.isEmpty
                  ? all
                  : all
                      .where((f) => f.name.toLowerCase().contains(_query.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                return Center(child: Text(loc.addFoodNoProductsYet));
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final food = filtered[index];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text(loc.addFoodKcalPer100g(food.kcalPer100g.round())),
                    trailing: IconButton(
                      icon: Icon(food.isFavorite ? Icons.star : Icons.star_border),
                      onPressed: () => _toggleFavorite(food),
                    ),
                    onTap: () async {
                      final saved = await showLogExistingFoodDialog(
                        context: context,
                        ref: ref,
                        food: food,
                      );
                      if (saved && mounted) _refresh();
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Wire `ManualTab` into `add_food_screen.dart`**

In `lib/ui/add_food/add_food_screen.dart`, add the import alongside the existing ones at the top of the file:

```dart
import 'package:callory/ui/add_food/manual_tab.dart';
```

Replace the `TabBarView` children (currently lines 51-57):

```dart
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RecentTab(),
          _SearchTab(),
          _BarcodeTab(),
          _ManualTab(),
        ],
      ),
```

with:

```dart
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RecentTab(),
          _SearchTab(),
          _BarcodeTab(),
          ManualTab(),
        ],
      ),
```

Then delete the old `_ManualTab` class entirely (currently lines 349-379):

```dart
class _ManualTab extends ConsumerWidget {
  const _ManualTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final saved = await showEditableFoodDialog(
            context: context,
            ref: ref,
            initial: const FoodResult(
              name: '',
              kcalPer100g: 0,
              proteinPer100g: 0,
              fatPer100g: 0,
              carbsPer100g: 0,
            ),
          );
          if (saved && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.addFoodSavedMessage)),
            );
          }
        },
        child: Text(loc.addFoodAddManuallyButton),
      ),
    );
  }
}

```

(delete the whole block, including the trailing blank line before `Future<bool> showEditableFoodDialog`).

- [ ] **Step 5: Run the new tests to verify they pass**

Run: `flutter test test/ui/manual_tab_test.dart`
Expected: PASS — all 8 tests in the file (2 from Task 4, 2 from Task 5, 4 from this task).

- [ ] **Step 6: Run the full test suite**

Run: `flutter test`
Expected: PASS — no regressions across `test/data/food_repository_test.dart`, `test/ui/add_food_screen_test.dart`, `test/ui/day_screen_test.dart`, `test/ui/goals_screen_test.dart`, `test/ui/settings_screen_test.dart`, `test/ui/manual_tab_test.dart`, and any other existing tests. In particular, `test/ui/add_food_screen_test.dart`'s `'initial tab is Recent and tab order is Recent Search Barcode Manual'` test must still pass — it only checks tab labels, which are unchanged.

- [ ] **Step 7: Commit**

```bash
git add lib/ui/add_food/manual_tab.dart lib/ui/add_food/add_food_screen.dart test/ui/manual_tab_test.dart
git commit -m "feat: redesign Manual tab with product list, search, and grams-only logging"
```
