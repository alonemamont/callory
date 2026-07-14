# Callory MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the offline Flutter calorie/macro tracker described in `docs/superpowers/specs/2026-07-13-callory-design.md` — private food database, gap-based editable meal grouping, BMR-based or manual goals, JSON export/import.

> **Revised 2026-07-14** to follow the spec revisions made in response to `docs/superpowers/specs/2026-07-14-callory-spec-review.md`. Nothing had been implemented yet at the time of revision, so this plan was edited directly rather than patched post-hoc. Changed: Task 2 (schema — `occurred_at`/`created_at`/`updated_at`, `ON DELETE SET NULL`), Task 3 (grouping algorithm rewritten as a full deterministic regroup), Task 8 (`DiaryRepository` rebuilt around one `regroupDay`, plus `deleteEntry`/`splitEntriesIntoNewMeal`/`mergeMeals`), Task 9 (confirmed, no code change), Task 10/13 (added tests), Task 15 (meal display order fix), and every call site that referenced the old `loggedAt` field name.

**Architecture:** UI (widgets) → Riverpod providers → Repositories (Food/Diary/Goals) → Drift (SQLite) local storage. Food lookup goes through a `FoodSource` interface with two MVP implementations: the user's private food database and Open Food Facts (keyless HTTP). No backend, no accounts.

**Tech Stack:** Flutter, Riverpod (`flutter_riverpod`), Drift (SQLite) for local storage, `http` for Open Food Facts, `mobile_scanner` for barcode scanning, `shared_preferences` for the gap-window setting, `file_picker` + `share_plus` for JSON export/import.

## Global Constraints

- Offline-first app: no backend, no user accounts, no cloud sync; Open Food Facts lookup is the one HTTP dependency and degrades gracefully offline (per spec Overview).
- MVP nutrient scope is exactly kcal + protein + fat + carbs — no other nutrients, no weight/water tracking (per spec Overview).
- Quantity input is grams-only in MVP (per spec Overview); `grams` must be `> 0`, nutrient fields `>= 0` (per spec "Domain rules and constraints").
- Diary entries snapshot nutrition at log time; editing or deleting a `PrivateFood` must never change past `DiaryEntry` values — deleting a `PrivateFood` sets `private_food_id` to `NULL` via `ON DELETE SET NULL` (per spec "Nutrition snapshotting" and "Domain rules and constraints").
- Meal grouping is a full deterministic regroup of the auto (non-manual) partition based on `occurred_at`, evaluated within a single `entry_date`, re-run on every add/edit/delete — never an incremental "compare to the last meal" step. `Meal` rows with `is_manual = true` are never touched by auto-regrouping, and any meal (manual or auto) left empty is deleted (per spec "Meal grouping algorithm" and "Manual meal invariants").
- FatSecret is explicitly excluded from MVP (no backend to hold its client secret); only `OpenFoodFactsSource` (keyless) and the private food database are built. `FoodSource` is an interface so a paid source can be added later (per spec "Food sources").
- JSON import is a full replacement of local data, never a merge, and is atomic — any failure mid-import leaves the existing database unchanged (per spec "Export / Import").
- `Goals` is a single current record with no per-day history; the day view always shows the current goal regardless of which date is selected (per spec "Goals and BMR/TDEE calculation" > Goals history).
- Free app, no monetization, no ads SDKs.

---

## File Structure

```
callory/
  pubspec.yaml
  lib/
    main.dart
    db/
      database.dart              # Drift tables + AppDatabase
    domain/
      meal_grouping.dart          # clusterAutoEntries() pure function
      bmr_calculator.dart         # calculateGoals() pure function
      entry_rescale.dart          # rescaleSnapshot() pure function
      food_source.dart            # FoodSource interface + FoodResult model
    data/
      food_repository.dart        # PrivateFood CRUD + search
      diary_repository.dart       # Meal + DiaryEntry CRUD, regrouping
      goals_repository.dart       # Goals CRUD wired to bmr_calculator
      open_food_facts_source.dart # FoodSource impl over OFF HTTP API
      food_lookup_service.dart    # combines private + external FoodSource
      settings_service.dart       # gap-window setting via SharedPreferences
      export_import_service.dart  # JSON export/import
    providers/
      providers.dart              # all Riverpod providers
    ui/
      day/
        day_screen.dart
      add_food/
        add_food_screen.dart
      goals/
        goals_screen.dart
      settings/
        settings_screen.dart
  test/
    domain/
      meal_grouping_test.dart
      bmr_calculator_test.dart
      entry_rescale_test.dart
    data/
      food_repository_test.dart
      diary_repository_test.dart
      goals_repository_test.dart
      open_food_facts_source_test.dart
      food_lookup_service_test.dart
      settings_service_test.dart
      export_import_service_test.dart
    ui/
      day_screen_test.dart
      goals_screen_test.dart
```

Repositories are the only layer that talks to Drift or HTTP. `domain/` is pure Dart with no Flutter/Drift/HTTP imports, so it's fast to test and has zero setup cost. UI never imports `db/` or `data/` directly — only through providers.

---

### Task 1: Scaffold Flutter project and dependencies

**Files:**
- Create: whole Flutter project skeleton via `flutter create` (lib/main.dart, android/, ios/, pubspec.yaml, etc.)
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: a runnable Flutter project with all packages this plan depends on installed.

- [ ] **Step 1: Scaffold the project**

Run from the repo root (`C:\Users\kg\work\callory`):

```bash
flutter create --org com.callory --project-name callory .
```

This will regenerate `README.md` with Flutter's boilerplate content — that's expected and fine, the original file only had a one-line title.

- [ ] **Step 2: Add dependencies to `pubspec.yaml`**

Edit the generated `pubspec.yaml`, adding to `dependencies:` (keep the existing `flutter:` and `cupertino_icons:` entries):

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.5.1
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0
  http: ^1.2.2
  mobile_scanner: ^5.2.3
  shared_preferences: ^2.3.2
  file_picker: ^8.1.2
  share_plus: ^10.0.2
```

And to `dev_dependencies:` (keep the existing `flutter_test:` and `flutter_lints:` entries):

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.20.0
  build_runner: ^2.4.11
```

- [ ] **Step 3: Install and verify**

```bash
flutter pub get
```

Expected: resolves with no errors. If a version constraint conflicts, bump the offending package to the latest version `flutter pub get` suggests.

```bash
flutter test
```

Expected: PASS (the default counter-app widget test that `flutter create` generates).

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: scaffold Flutter project with core dependencies"
```

---

### Task 2: Drift schema and database class

**Files:**
- Create: `lib/db/database.dart`
- Test: `test/data/food_repository_test.dart` (schema is exercised for the first time in Task 6; this task just proves the schema compiles and opens)

**Interfaces:**
- Produces: `AppDatabase` class, tables `PrivateFoods`, `Meals`, `DiaryEntries`, `Goals`, enums `FoodSourceType` and `GoalsMode`, generated row classes `PrivateFood`, `Meal`, `DiaryEntry`, `Goal` and companions `PrivateFoodsCompanion`, `MealsCompanion`, `DiaryEntriesCompanion`, `GoalsCompanion`.

- [ ] **Step 1: Write the schema**

Create `lib/db/database.dart`:

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

enum FoodSourceType { barcode, manual, copiedExternal }

enum GoalsMode { calculated, manual }

class PrivateFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()(); // intentionally not unique — see spec "Domain rules and constraints"
  RealColumn get kcalPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get carbsPer100g => real()();
  IntColumn get source => intEnum<FoodSourceType>()();
  DateTimeColumn get createdAt => dateTime()();
}

class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dayDate => dateTime()();
  IntColumn get mealNumber => integer()();
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();
}

class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealId => integer().references(Meals, #id)();
  IntColumn get privateFoodId => integer()
      .nullable()
      .references(PrivateFoods, #id, onDelete: KeyAction.setNull)();
  TextColumn get foodNameSnapshot => text()();
  RealColumn get grams => real()();
  RealColumn get kcalSnapshot => real()();
  RealColumn get proteinSnapshot => real()();
  RealColumn get fatSnapshot => real()();
  RealColumn get carbsSnapshot => real()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get entryDate => dateTime()();
}

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get dailyKcal => real()();
  RealColumn get dailyProtein => real()();
  RealColumn get dailyFat => real()();
  RealColumn get dailyCarbs => real()();
  IntColumn get mode => intEnum<GoalsMode>()();
  IntColumn get age => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get sex => text().nullable()();
  TextColumn get activityLevel => text().nullable()();
  TextColumn get goalType => text().nullable()();
}

@DriftDatabase(tables: [PrivateFoods, Meals, DiaryEntries, Goals])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Required for the DiaryEntries.privateFoodId ON DELETE SET NULL
          // action to actually fire — SQLite does not enforce FKs by default.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'callory.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
```

- [ ] **Step 2: Generate Drift code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: creates `lib/db/database.g.dart` with no errors.

- [ ] **Step 3: Verify it compiles**

```bash
flutter analyze lib/db/database.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/db/database.dart lib/db/database.g.dart
git commit -m "feat: add Drift schema for foods, meals, diary entries, goals"
```

---

### Task 3: Meal grouping algorithm

> **Revised after spec review** (`2026-07-14-callory-spec-review.md`): the original design compared each new entry only to "the last non-manual meal," which breaks for backdated entries (chronologically-earlier `occurred_at`) and can't handle inserting an entry in the middle of a day. Replaced with a pure clustering function that always re-derives auto-meal groups from a full sorted pass, matching the spec's "Meal grouping algorithm" section. This function has no notion of "last meal" or incremental comparison at all — every caller (add/edit/delete) always recomputes the full clustering for the day's auto-partition, per spec.

**Files:**
- Create: `lib/domain/meal_grouping.dart`
- Test: `test/domain/meal_grouping_test.dart`

**Interfaces:**
- Produces: `AutoEntry` (`{int id, DateTime occurredAt}`), `MealCluster` (`{int mealNumber, List<int> entryIds}`), `List<MealCluster> clusterAutoEntries({required List<AutoEntry> autoEntries, required Duration gapWindow, required int startingMealNumber})`. `autoEntries` is expected to already exclude any entry currently assigned to a manual meal — filtering that out is the caller's (`DiaryRepository`'s) job, per spec "Manual meal invariants." `startingMealNumber` is `(max manual meal_number for the day, or 0) + 1`.
- Consumes: nothing (pure Dart, no Flutter/Drift imports).

- [ ] **Step 1: Write the failing tests**

Create `test/domain/meal_grouping_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/domain/meal_grouping.dart';

void main() {
  const gapWindow = Duration(minutes: 90);

  test('empty input produces no clusters', () {
    final clusters = clusterAutoEntries(
      autoEntries: [],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, isEmpty);
  });

  test('two entries within the gap form a single cluster', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 8, 30)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(1));
    expect(clusters.single.mealNumber, 1);
    expect(clusters.single.entryIds, [1, 2]);
  });

  test('entry exactly at the gap boundary joins the same cluster', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 9, 30)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(1));
    expect(clusters.single.entryIds, [1, 2]);
  });

  test('entry just past the gap starts a new cluster', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 9, 31)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(2));
    expect(clusters[0].entryIds, [1]);
    expect(clusters[1].entryIds, [2]);
    expect(clusters.map((c) => c.mealNumber).toList(), [1, 2]);
  });

  test('clustering sorts by occurredAt regardless of input order, fixing the insert-in-the-middle case', () {
    // Entry 3 is passed first but its occurredAt falls between entries 1 and 2.
    // All three are within gapWindow of their chronological neighbor, so they
    // must all land in one cluster no matter what order they're supplied in.
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 3, occurredAt: DateTime(2026, 7, 14, 8, 30)),
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 9, 0)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(1));
    expect(clusters.single.entryIds, [1, 3, 2]);
  });

  test('backdating an entry earlier than everything else never produces a negative-gap false match', () {
    // Old bug: comparing only against "the last meal" let a much-earlier
    // occurredAt produce a negative time difference, which satisfied
    // `<= gapWindow` and silently joined the wrong meal. Sorting first
    // makes this impossible: entry 4 is 5 hours before entry 1, so it must
    // start its own cluster.
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 13, 0)),
        AutoEntry(id: 4, occurredAt: DateTime(2026, 7, 14, 8, 0)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(2));
    expect(clusters[0].entryIds, [4]);
    expect(clusters[1].entryIds, [1]);
  });

  test('startingMealNumber offsets past existing manual meal numbers', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 6, // e.g. a manual meal already holds number 5
    );
    expect(clusters.single.mealNumber, 6);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/domain/meal_grouping_test.dart
```

Expected: FAIL — `package:callory/domain/meal_grouping.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

Create `lib/domain/meal_grouping.dart`:

```dart
class AutoEntry {
  final int id;
  final DateTime occurredAt;

  const AutoEntry({required this.id, required this.occurredAt});
}

class MealCluster {
  final int mealNumber;
  final List<int> entryIds;

  const MealCluster({required this.mealNumber, required this.entryIds});
}

/// Deterministically clusters [autoEntries] (which must already exclude any
/// entry currently in a manual meal) into meals using rolling-gap grouping.
/// Always re-derives the full clustering from a fresh sort — there is no
/// incremental "compare to the last meal" step, so inserting an entry
/// anywhere in the day (including earlier than existing entries) is handled
/// correctly by construction.
List<MealCluster> clusterAutoEntries({
  required List<AutoEntry> autoEntries,
  required Duration gapWindow,
  required int startingMealNumber,
}) {
  final sorted = [...autoEntries]..sort((a, b) {
      final byTime = a.occurredAt.compareTo(b.occurredAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });

  final clusters = <MealCluster>[];
  var mealNumber = startingMealNumber;
  List<int>? currentIds;
  DateTime? previousOccurredAt;

  for (final entry in sorted) {
    final startsNewCluster = currentIds == null ||
        entry.occurredAt.difference(previousOccurredAt!) > gapWindow;

    if (startsNewCluster) {
      currentIds = <int>[];
      clusters.add(MealCluster(mealNumber: mealNumber, entryIds: currentIds));
      mealNumber++;
    }

    currentIds!.add(entry.id);
    previousOccurredAt = entry.occurredAt;
  }

  return clusters;
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/domain/meal_grouping_test.dart
```

Expected: PASS, all 7 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/meal_grouping.dart test/domain/meal_grouping_test.dart
git commit -m "feat: add deterministic full-day meal clustering algorithm"
```

---

### Task 4: BMR/TDEE calculator

**Files:**
- Create: `lib/domain/bmr_calculator.dart`
- Test: `test/domain/bmr_calculator_test.dart`

**Interfaces:**
- Produces: `Sex` (`male`, `female`), `ActivityLevel` (`sedentary`, `light`, `moderate`, `high`), `GoalType` (`lose`, `maintain`, `gain`), `BmrInput` (`{Sex sex, int age, double weightKg, double heightCm, ActivityLevel activityLevel, GoalType goalType}`), `MacroGoals` (`{double kcal, double proteinG, double fatG, double carbsG}`), `MacroGoals calculateGoals(BmrInput input)`.

- [ ] **Step 1: Write the failing test**

Create `test/domain/bmr_calculator_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/domain/bmr_calculator.dart';

void main() {
  test('male, moderate activity, maintain: matches Mifflin-St Jeor by hand', () {
    // BMR = 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
    // TDEE = 1780 * 1.55 = 2759
    // maintain adjustment = 0% => kcal = 2759
    const input = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
    );

    final result = calculateGoals(input);

    expect(result.kcal, closeTo(2759, 0.5));
    expect(result.proteinG, closeTo(2759 * 0.30 / 4, 0.1));
    expect(result.fatG, closeTo(2759 * 0.30 / 9, 0.1));
    expect(result.carbsG, closeTo(2759 * 0.40 / 4, 0.1));
  });

  test('female, sedentary, lose: applies -20% adjustment', () {
    // BMR = 10*60 + 6.25*165 - 5*25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
    // TDEE = 1345.25 * 1.2 = 1614.3
    // lose adjustment = -20% => kcal = 1291.44
    const input = BmrInput(
      sex: Sex.female,
      age: 25,
      weightKg: 60,
      heightCm: 165,
      activityLevel: ActivityLevel.sedentary,
      goalType: GoalType.lose,
    );

    final result = calculateGoals(input);

    expect(result.kcal, closeTo(1291.44, 0.5));
  });

  test('gain applies +15% adjustment', () {
    const maintainInput = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
    );
    const gainInput = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.gain,
    );

    final maintainKcal = calculateGoals(maintainInput).kcal;
    final gainKcal = calculateGoals(gainInput).kcal;

    expect(gainKcal, closeTo(maintainKcal * 1.15, 0.5));
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/domain/bmr_calculator_test.dart
```

Expected: FAIL — module doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/domain/bmr_calculator.dart`:

```dart
enum Sex { male, female }

enum ActivityLevel { sedentary, light, moderate, high }

enum GoalType { lose, maintain, gain }

class BmrInput {
  final Sex sex;
  final int age;
  final double weightKg;
  final double heightCm;
  final ActivityLevel activityLevel;
  final GoalType goalType;

  const BmrInput({
    required this.sex,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    required this.goalType,
  });
}

class MacroGoals {
  final double kcal;
  final double proteinG;
  final double fatG;
  final double carbsG;

  const MacroGoals({
    required this.kcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });
}

const _activityMultipliers = {
  ActivityLevel.sedentary: 1.2,
  ActivityLevel.light: 1.375,
  ActivityLevel.moderate: 1.55,
  ActivityLevel.high: 1.725,
};

const _goalAdjustments = {
  GoalType.lose: -0.20,
  GoalType.maintain: 0.0,
  GoalType.gain: 0.15,
};

MacroGoals calculateGoals(BmrInput input) {
  final bmr = input.sex == Sex.male
      ? 10 * input.weightKg + 6.25 * input.heightCm - 5 * input.age + 5
      : 10 * input.weightKg + 6.25 * input.heightCm - 5 * input.age - 161;

  final tdee = bmr * _activityMultipliers[input.activityLevel]!;
  final kcal = tdee * (1 + _goalAdjustments[input.goalType]!);

  return MacroGoals(
    kcal: kcal,
    proteinG: (kcal * 0.30) / 4,
    fatG: (kcal * 0.30) / 9,
    carbsG: (kcal * 0.40) / 4,
  );
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/domain/bmr_calculator_test.dart
```

Expected: PASS, all 3 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/bmr_calculator.dart test/domain/bmr_calculator_test.dart
git commit -m "feat: add Mifflin-St Jeor BMR/TDEE goal calculator"
```

---

### Task 5: Entry rescale helper

**Files:**
- Create: `lib/domain/entry_rescale.dart`
- Test: `test/domain/entry_rescale_test.dart`

**Interfaces:**
- Produces: `NutrientSnapshot` (`{double kcal, double protein, double fat, double carbs}`), `NutrientSnapshot rescaleSnapshot({required NutrientSnapshot original, required double oldGrams, required double newGrams})`.

- [ ] **Step 1: Write the failing test**

Create `test/domain/entry_rescale_test.dart`:

```dart
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
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/domain/entry_rescale_test.dart
```

Expected: FAIL — module doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/domain/entry_rescale.dart`:

```dart
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
  assert(oldGrams > 0, 'oldGrams must be positive to rescale a snapshot');
  final ratio = newGrams / oldGrams;
  return NutrientSnapshot(
    kcal: original.kcal * ratio,
    protein: original.protein * ratio,
    fat: original.fat * ratio,
    carbs: original.carbs * ratio,
  );
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/domain/entry_rescale_test.dart
```

Expected: PASS, all 3 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entry_rescale.dart test/domain/entry_rescale_test.dart
git commit -m "feat: add proportional snapshot rescale helper"
```

---

### Task 6: FoodSource interface and FoodResult model

**Files:**
- Create: `lib/domain/food_source.dart`

**Interfaces:**
- Produces: `FoodResult` (`{String name, String? barcode, double kcalPer100g, double proteinPer100g, double fatPer100g, double carbsPer100g, int? existingPrivateFoodId}`), `abstract class FoodSource { Future<List<FoodResult>> searchByName(String query); Future<FoodResult?> lookupBarcode(String barcode); }`.

This is a pure interface/model with no logic to unit test — it's exercised by Tasks 7 and 8's tests.

- [ ] **Step 1: Write the file**

Create `lib/domain/food_source.dart`:

```dart
class FoodResult {
  final String name;
  final String? barcode;
  final double kcalPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  /// Non-null when this result already exists in the user's private food
  /// database (so the UI can skip the "copy to private db" step).
  final int? existingPrivateFoodId;

  const FoodResult({
    required this.name,
    this.barcode,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    this.existingPrivateFoodId,
  });
}

abstract class FoodSource {
  Future<List<FoodResult>> searchByName(String query);
  Future<FoodResult?> lookupBarcode(String barcode);
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/domain/food_source.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/food_source.dart
git commit -m "feat: add FoodSource interface and FoodResult model"
```

---

### Task 7: FoodRepository (private food CRUD + search)

**Files:**
- Create: `lib/data/food_repository.dart`
- Test: `test/data/food_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 2), `FoodResult`/`FoodSource` (Task 6).
- Produces: `FoodRepository` with `insertFood(...)`, `updateFood(int id, {...})`, `deleteFood(int id)`, `findByBarcode(String barcode)`, `searchByName(String query)` — the latter two implement `FoodSource`.

- [ ] **Step 1: Write the failing test**

Create `test/data/food_repository_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/food_repository.dart';

void main() {
  late AppDatabase db;
  late FoodRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FoodRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insert then find by barcode returns the inserted food', () async {
    final id = await repo.insertFood(
      name: 'Test Yogurt',
      barcode: '1234567890123',
      kcalPer100g: 60,
      proteinPer100g: 5,
      fatPer100g: 2,
      carbsPer100g: 7,
      source: FoodSourceType.barcode,
    );

    final result = await repo.findByBarcode('1234567890123');

    expect(result, isNotNull);
    expect(result!.name, 'Test Yogurt');
    expect(result.existingPrivateFoodId, id);
  });

  test('searchByName is case-insensitive and matches substrings', () async {
    await repo.insertFood(
      name: 'Greek Yogurt',
      kcalPer100g: 90,
      proteinPer100g: 10,
      fatPer100g: 4,
      carbsPer100g: 4,
      source: FoodSourceType.manual,
    );

    final results = await repo.searchByName('yogurt');

    expect(results, hasLength(1));
    expect(results.first.name, 'Greek Yogurt');
  });

  test('updateFood changes the stored macros', () async {
    final id = await repo.insertFood(
      name: 'Oats',
      kcalPer100g: 380,
      proteinPer100g: 13,
      fatPer100g: 7,
      carbsPer100g: 67,
      source: FoodSourceType.manual,
    );

    await repo.updateFood(
      id,
      name: 'Oats',
      kcalPer100g: 390,
      proteinPer100g: 13,
      fatPer100g: 7,
      carbsPer100g: 68,
    );

    final results = await repo.searchByName('Oats');
    expect(results.first.kcalPer100g, 390);
  });

  test('deleteFood removes it from search results', () async {
    final id = await repo.insertFood(
      name: 'Deleted Item',
      kcalPer100g: 100,
      proteinPer100g: 1,
      fatPer100g: 1,
      carbsPer100g: 1,
      source: FoodSourceType.manual,
    );

    await repo.deleteFood(id);

    final results = await repo.searchByName('Deleted');
    expect(results, isEmpty);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/food_repository_test.dart
```

Expected: FAIL — `FoodRepository` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/data/food_repository.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';

class FoodRepository implements FoodSource {
  final AppDatabase db;
  FoodRepository(this.db);

  Future<int> insertFood({
    required String name,
    String? barcode,
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    required FoodSourceType source,
  }) {
    return db.into(db.privateFoods).insert(PrivateFoodsCompanion.insert(
          name: name,
          barcode: Value(barcode),
          kcalPer100g: kcalPer100g,
          proteinPer100g: proteinPer100g,
          fatPer100g: fatPer100g,
          carbsPer100g: carbsPer100g,
          source: source,
          createdAt: DateTime.now(),
        ));
  }

  Future<void> updateFood(
    int id, {
    required String name,
    String? barcode,
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
  }) {
    return (db.update(db.privateFoods)..where((f) => f.id.equals(id))).write(
      PrivateFoodsCompanion(
        name: Value(name),
        barcode: Value(barcode),
        kcalPer100g: Value(kcalPer100g),
        proteinPer100g: Value(proteinPer100g),
        fatPer100g: Value(fatPer100g),
        carbsPer100g: Value(carbsPer100g),
      ),
    );
  }

  Future<void> deleteFood(int id) =>
      (db.delete(db.privateFoods)..where((f) => f.id.equals(id))).go();

  Future<FoodResult?> findByBarcode(String barcode) async {
    final row = await (db.select(db.privateFoods)
          ..where((f) => f.barcode.equals(barcode)))
        .getSingleOrNull();
    return row == null ? null : _toResult(row);
  }

  @override
  Future<FoodResult?> lookupBarcode(String barcode) => findByBarcode(barcode);

  @override
  Future<List<FoodResult>> searchByName(String query) async {
    final rows = await (db.select(db.privateFoods)
          ..where((f) => f.name.lower().like('%${query.toLowerCase()}%'))
          ..orderBy([(f) => OrderingTerm.asc(f.name)]))
        .get();
    return rows.map(_toResult).toList();
  }

  FoodResult _toResult(PrivateFood row) => FoodResult(
        name: row.name,
        barcode: row.barcode,
        kcalPer100g: row.kcalPer100g,
        proteinPer100g: row.proteinPer100g,
        fatPer100g: row.fatPer100g,
        carbsPer100g: row.carbsPer100g,
        existingPrivateFoodId: row.id,
      );
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/food_repository_test.dart
```

Expected: PASS, all 4 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/data/food_repository.dart test/data/food_repository_test.dart
git commit -m "feat: add FoodRepository for private food CRUD and search"
```

---

### Task 8: DiaryRepository (meals, entries, regrouping)

> **Revised after spec review**: `addEntry`, `updateEntryOccurredAt` (renamed from `updateEntryLoggedAt`), and the new `deleteEntry` all funnel through one `regroupDay`, which now uses `clusterAutoEntries` (Task 3) for a full deterministic rebuild instead of the old incremental compare-to-last-meal step. Added `deleteEntry`, `splitEntriesIntoNewMeal`, and `mergeMeals` to cover the move/split/merge state-transition matrix the spec now defines explicitly; `reassignEntryToMeal` is renamed `moveEntryToMeal` to match spec terminology. Empty-meal cleanup now applies to manual meals too, not just auto ones.

**Files:**
- Create: `lib/data/diary_repository.dart`
- Test: `test/data/diary_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 2), `clusterAutoEntries`/`AutoEntry` (Task 3), `rescaleSnapshot`/`NutrientSnapshot` (Task 5).
- Produces: `DiaryRepository` with `addEntry(...)` (param `occurredAt` replaces `loggedAt`), `updateEntryGrams(int entryId, double newGrams)`, `updateEntryOccurredAt(int entryId, DateTime newOccurredAt, Duration gapWindow)`, `deleteEntry(int entryId, Duration gapWindow)`, `regroupDay(DateTime date, Duration gapWindow)`, `moveEntryToMeal(int entryId, int targetMealId)`, `splitEntriesIntoNewMeal({required List<int> entryIds, required DateTime date, required int newMealNumber})`, `mergeMeals({required int keepMealId, required int otherMealId})`, `createManualMeal(DateTime date, int mealNumber)`, `getEntriesForDate(DateTime date)`, `getMealsForDate(DateTime date)`.

- [ ] **Step 1: Write the failing tests**

Create `test/data/diary_repository_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/diary_repository.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository repo;
  const gapWindow = Duration(minutes: 90);
  final day = DateTime(2026, 7, 14);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DiaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> addEggs(DateTime occurredAt) => repo.addEntry(
        foodNameSnapshot: 'Eggs',
        grams: 100,
        kcalPer100g: 150,
        proteinPer100g: 12,
        fatPer100g: 10,
        carbsPer100g: 1,
        entryDate: day,
        occurredAt: occurredAt,
        gapWindow: gapWindow,
      );

  test('two entries within the gap land in the same meal', () async {
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    await addEggs(DateTime(2026, 7, 14, 8, 20));

    final meals = await repo.getMealsForDate(day);
    expect(meals, hasLength(1));
    expect(meals.first.mealNumber, 1);

    final entries = await repo.getEntriesForDate(day);
    expect(entries, hasLength(2));
    expect(entries.every((e) => e.mealId == meals.first.id), true);
  });

  test('entries past the gap create a second meal', () async {
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    await addEggs(DateTime(2026, 7, 14, 13, 0));

    final meals = await repo.getMealsForDate(day);
    expect(meals, hasLength(2));
    expect(meals.map((m) => m.mealNumber).toList(), [1, 2]);
  });

  test('addEntry stores a nutrition snapshot scaled to grams and stamps createdAt', () async {
    await repo.addEntry(
      foodNameSnapshot: 'Chicken Breast',
      grams: 150,
      kcalPer100g: 165,
      proteinPer100g: 31,
      fatPer100g: 3.6,
      carbsPer100g: 0,
      entryDate: day,
      occurredAt: DateTime(2026, 7, 14, 12, 0),
      gapWindow: gapWindow,
    );

    final entries = await repo.getEntriesForDate(day);
    expect(entries.single.kcalSnapshot, closeTo(247.5, 0.01));
    expect(entries.single.proteinSnapshot, closeTo(46.5, 0.01));
    expect(entries.single.createdAt, isNotNull);
    expect(entries.single.updatedAt, isNull);
  });

  test('adding an entry chronologically between two existing entries merges all three into one meal regardless of add order', () async {
    // Regression test for the "last non-manual meal" bug: the middle entry
    // is added last, after two entries that are already 90+ minutes apart at
    // the DB level from each other's perspective, but each neighbor is
    // within gapWindow of the middle entry.
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    await addEggs(DateTime(2026, 7, 14, 9, 0));
    await addEggs(DateTime(2026, 7, 14, 8, 30)); // added last, sorts in the middle

    final meals = await repo.getMealsForDate(day);
    expect(meals, hasLength(1));
    final entries = await repo.getEntriesForDate(day);
    expect(entries, hasLength(3));
  });

  test('updateEntryGrams rescales from the original snapshot ratio, not current food data', () async {
    final id = await repo.addEntry(
      foodNameSnapshot: 'Rice',
      grams: 100,
      kcalPer100g: 130,
      proteinPer100g: 3,
      fatPer100g: 0.3,
      carbsPer100g: 28,
      entryDate: day,
      occurredAt: DateTime(2026, 7, 14, 12, 0),
      gapWindow: gapWindow,
    );

    await repo.updateEntryGrams(id, 200);

    final entries = await repo.getEntriesForDate(day);
    expect(entries.single.grams, 200);
    expect(entries.single.kcalSnapshot, closeTo(260, 0.01));
    expect(entries.single.updatedAt, isNotNull);
  });

  test('moveEntryToMeal marks the target meal manual and deletes an emptied source meal', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final manualMealId = await repo.createManualMeal(day, 5);
    final sourceMealId =
        (await repo.getEntriesForDate(day)).single.mealId;

    await repo.moveEntryToMeal(entryId, manualMealId);

    final entries = await repo.getEntriesForDate(day);
    expect(entries.single.mealId, manualMealId);

    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == sourceMealId), false); // emptied source removed
    final manualMeal = meals.firstWhere((m) => m.id == manualMealId);
    expect(manualMeal.isManual, true);
  });

  test('updateEntryOccurredAt regroups the day but leaves manual meals untouched', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final manualMealId = await repo.createManualMeal(day, 99);
    final snackId = await addEggs(DateTime(2026, 7, 14, 16, 0));
    await repo.moveEntryToMeal(snackId, manualMealId);

    // Move the first entry far past the gap from its original meal.
    await repo.updateEntryOccurredAt(
      entryId,
      DateTime(2026, 7, 14, 20, 0),
      gapWindow,
    );

    final meals = await repo.getMealsForDate(day);
    final manualMeal = meals.firstWhere((m) => m.id == manualMealId);
    expect(manualMeal.isManual, true);
    expect(manualMeal.mealNumber, 99);

    final entries = await repo.getEntriesForDate(day);
    final movedEntry = entries.firstWhere((e) => e.id == entryId);
    expect(movedEntry.mealId, isNot(manualMealId));
  });

  test('deleteEntry removes the row and cleans up an emptied auto meal', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final mealId = (await repo.getEntriesForDate(day)).single.mealId;

    await repo.deleteEntry(entryId, gapWindow);

    expect(await repo.getEntriesForDate(day), isEmpty);
    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == mealId), false);
  });

  test('deleting the last entry in a manual meal removes that manual meal too', () async {
    final entryId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final manualMealId = await repo.createManualMeal(day, 7);
    await repo.moveEntryToMeal(entryId, manualMealId);

    await repo.deleteEntry(entryId, gapWindow);

    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == manualMealId), false);
  });

  test('splitEntriesIntoNewMeal creates a manual meal and marks the source meal manual too', () async {
    await addEggs(DateTime(2026, 7, 14, 8, 0));
    final secondId = await addEggs(DateTime(2026, 7, 14, 8, 20));
    final sourceMealId = (await repo.getEntriesForDate(day)).first.mealId;

    final newMealId = await repo.splitEntriesIntoNewMeal(
      entryIds: [secondId],
      date: day,
      newMealNumber: 50,
    );

    final meals = await repo.getMealsForDate(day);
    final newMeal = meals.firstWhere((m) => m.id == newMealId);
    expect(newMeal.isManual, true);
    final sourceMeal = meals.firstWhere((m) => m.id == sourceMealId);
    expect(sourceMeal.isManual, true); // touched by the split, so it's locked too

    final entries = await repo.getEntriesForDate(day);
    expect(entries.firstWhere((e) => e.id == secondId).mealId, newMealId);
  });

  test('mergeMeals combines two meals into one manual meal and deletes the other', () async {
    final firstId = await addEggs(DateTime(2026, 7, 14, 8, 0));
    final secondId = await addEggs(DateTime(2026, 7, 14, 13, 0));
    final entries = await repo.getEntriesForDate(day);
    final firstMealId = entries.firstWhere((e) => e.id == firstId).mealId;
    final secondMealId = entries.firstWhere((e) => e.id == secondId).mealId;

    await repo.mergeMeals(keepMealId: firstMealId, otherMealId: secondMealId);

    final meals = await repo.getMealsForDate(day);
    expect(meals.any((m) => m.id == secondMealId), false);
    final keptMeal = meals.firstWhere((m) => m.id == firstMealId);
    expect(keptMeal.isManual, true);

    final updatedEntries = await repo.getEntriesForDate(day);
    expect(updatedEntries.every((e) => e.mealId == firstMealId), true);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/diary_repository_test.dart
```

Expected: FAIL — `DiaryRepository` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/data/diary_repository.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/meal_grouping.dart';
import 'package:callory/domain/entry_rescale.dart';

class DiaryRepository {
  final AppDatabase db;
  DiaryRepository(this.db);

  DateTime _dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<int> addEntry({
    int? privateFoodId,
    required String foodNameSnapshot,
    required double grams,
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    required DateTime entryDate,
    required DateTime occurredAt,
    required Duration gapWindow,
  }) async {
    assert(grams > 0, 'grams must be positive');
    final dayStart = _dayStart(entryDate);
    final ratio = grams / 100.0;

    return db.transaction(() async {
      // Insert into a throwaway placeholder meal — regroupDay always
      // rebuilds the auto partition from scratch and will assign this
      // entry (and delete the placeholder, since it'll be empty) to the
      // correct cluster in one consistent pass.
      final placeholderMealId = await db.into(db.meals).insert(
            MealsCompanion.insert(dayDate: dayStart, mealNumber: 0),
          );

      final entryId = await db.into(db.diaryEntries).insert(
            DiaryEntriesCompanion.insert(
              mealId: placeholderMealId,
              privateFoodId: Value(privateFoodId),
              foodNameSnapshot: foodNameSnapshot,
              grams: grams,
              kcalSnapshot: kcalPer100g * ratio,
              proteinSnapshot: proteinPer100g * ratio,
              fatSnapshot: fatPer100g * ratio,
              carbsSnapshot: carbsPer100g * ratio,
              occurredAt: occurredAt,
              createdAt: DateTime.now(),
              entryDate: dayStart,
            ),
          );

      await regroupDay(dayStart, gapWindow);
      return entryId;
    });
  }

  Future<void> updateEntryGrams(int entryId, double newGrams) async {
    assert(newGrams > 0, 'grams must be positive');
    final entry =
        await (db.select(db.diaryEntries)..where((e) => e.id.equals(entryId)))
            .getSingle();

    final rescaled = rescaleSnapshot(
      original: NutrientSnapshot(
        kcal: entry.kcalSnapshot,
        protein: entry.proteinSnapshot,
        fat: entry.fatSnapshot,
        carbs: entry.carbsSnapshot,
      ),
      oldGrams: entry.grams,
      newGrams: newGrams,
    );

    await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
        .write(DiaryEntriesCompanion(
      grams: Value(newGrams),
      kcalSnapshot: Value(rescaled.kcal),
      proteinSnapshot: Value(rescaled.protein),
      fatSnapshot: Value(rescaled.fat),
      carbsSnapshot: Value(rescaled.carbs),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateEntryOccurredAt(
    int entryId,
    DateTime newOccurredAt,
    Duration gapWindow,
  ) async {
    final entry =
        await (db.select(db.diaryEntries)..where((e) => e.id.equals(entryId)))
            .getSingle();

    await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
        .write(DiaryEntriesCompanion(
      occurredAt: Value(newOccurredAt),
      updatedAt: Value(DateTime.now()),
    ));

    await regroupDay(entry.entryDate, gapWindow);
  }

  Future<void> deleteEntry(int entryId, Duration gapWindow) async {
    final entry =
        await (db.select(db.diaryEntries)..where((e) => e.id.equals(entryId)))
            .getSingle();

    await db.transaction(() async {
      await (db.delete(db.diaryEntries)..where((e) => e.id.equals(entryId)))
          .go();
      await regroupDay(entry.entryDate, gapWindow);
    });
  }

  /// Full deterministic regroup of the auto partition for [date], per the
  /// spec's "Meal grouping algorithm": every auto (non-manual) meal for the
  /// day is rebuilt from scratch via [clusterAutoEntries] on every call, so
  /// there is never an incremental "compare to the last meal" step. Manual
  /// meals and their entries are never touched. Any meal — manual or auto —
  /// left with zero entries afterward is deleted (manual meals can end up
  /// empty via [deleteEntry] or [moveEntryToMeal]).
  Future<void> regroupDay(DateTime date, Duration gapWindow) async {
    final dayStart = _dayStart(date);
    await db.transaction(() async {
      final meals =
          await (db.select(db.meals)..where((m) => m.dayDate.equals(dayStart)))
              .get();
      final manualMealIds =
          meals.where((m) => m.isManual).map((m) => m.id).toSet();
      final maxManualNumber = meals
          .where((m) => m.isManual)
          .fold<int>(0, (max, m) => m.mealNumber > max ? m.mealNumber : max);

      final entries = await (db.select(db.diaryEntries)
            ..where((e) => e.entryDate.equals(dayStart)))
          .get();
      final autoEntries = entries
          .where((e) => !manualMealIds.contains(e.mealId))
          .map((e) => AutoEntry(id: e.id, occurredAt: e.occurredAt))
          .toList();

      final clusters = clusterAutoEntries(
        autoEntries: autoEntries,
        gapWindow: gapWindow,
        startingMealNumber: maxManualNumber + 1,
      );

      for (final cluster in clusters) {
        final newMealId = await db.into(db.meals).insert(
              MealsCompanion.insert(
                dayDate: dayStart,
                mealNumber: cluster.mealNumber,
              ),
            );
        for (final entryId in cluster.entryIds) {
          await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
              .write(DiaryEntriesCompanion(mealId: Value(newMealId)));
        }
      }

      // Clean up every meal (manual or auto) now left with zero entries.
      for (final meal in meals) {
        final remaining = await (db.select(db.diaryEntries)
              ..where((e) => e.mealId.equals(meal.id)))
            .get();
        if (remaining.isEmpty) {
          await (db.delete(db.meals)..where((m) => m.id.equals(meal.id))).go();
        }
      }
    });
  }

  Future<void> moveEntryToMeal(int entryId, int targetMealId) async {
    await db.transaction(() async {
      final entry =
          await (db.select(db.diaryEntries)..where((e) => e.id.equals(entryId)))
              .getSingle();
      final sourceMealId = entry.mealId;

      await (db.update(db.meals)..where((m) => m.id.equals(targetMealId)))
          .write(const MealsCompanion(isManual: Value(true)));
      await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
          .write(DiaryEntriesCompanion(
        mealId: Value(targetMealId),
        updatedAt: Value(DateTime.now()),
      ));

      if (sourceMealId != targetMealId) {
        await _deleteMealIfEmpty(sourceMealId);
      }
    });
  }

  Future<int> splitEntriesIntoNewMeal({
    required List<int> entryIds,
    required DateTime date,
    required int newMealNumber,
  }) async {
    return db.transaction(() async {
      final newMealId = await createManualMeal(date, newMealNumber);
      final sourceMealIds = <int>{};

      for (final entryId in entryIds) {
        final entry = await (db.select(db.diaryEntries)
              ..where((e) => e.id.equals(entryId)))
            .getSingle();
        sourceMealIds.add(entry.mealId);
        await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
            .write(DiaryEntriesCompanion(
          mealId: Value(newMealId),
          updatedAt: Value(DateTime.now()),
        ));
      }

      for (final sourceMealId in sourceMealIds) {
        // A meal a split was carved out of is considered manually curated
        // even for the entries left behind, so auto-regroup never re-merges them.
        await (db.update(db.meals)..where((m) => m.id.equals(sourceMealId)))
            .write(const MealsCompanion(isManual: Value(true)));
        await _deleteMealIfEmpty(sourceMealId);
      }

      return newMealId;
    });
  }

  Future<void> mergeMeals({
    required int keepMealId,
    required int otherMealId,
  }) async {
    await db.transaction(() async {
      await (db.update(db.diaryEntries)..where((e) => e.mealId.equals(otherMealId)))
          .write(DiaryEntriesCompanion(
        mealId: Value(keepMealId),
        updatedAt: Value(DateTime.now()),
      ));
      await (db.update(db.meals)..where((m) => m.id.equals(keepMealId)))
          .write(const MealsCompanion(isManual: Value(true)));
      await (db.delete(db.meals)..where((m) => m.id.equals(otherMealId))).go();
    });
  }

  Future<void> _deleteMealIfEmpty(int mealId) async {
    final remaining = await (db.select(db.diaryEntries)
          ..where((e) => e.mealId.equals(mealId)))
        .get();
    if (remaining.isEmpty) {
      await (db.delete(db.meals)..where((m) => m.id.equals(mealId))).go();
    }
  }

  Future<int> createManualMeal(DateTime date, int mealNumber) {
    return db.into(db.meals).insert(MealsCompanion.insert(
          dayDate: _dayStart(date),
          mealNumber: mealNumber,
          isManual: const Value(true),
        ));
  }

  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) {
    final dayStart = _dayStart(date);
    return (db.select(db.diaryEntries)
          ..where((e) => e.entryDate.equals(dayStart))
          ..orderBy([(e) => OrderingTerm.asc(e.occurredAt)]))
        .get();
  }

  Future<List<Meal>> getMealsForDate(DateTime date) {
    final dayStart = _dayStart(date);
    return (db.select(db.meals)
          ..where((m) => m.dayDate.equals(dayStart))
          ..orderBy([(m) => OrderingTerm.asc(m.mealNumber)]))
        .get();
  }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/diary_repository_test.dart
```

Expected: PASS, all 11 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/data/diary_repository.dart test/data/diary_repository_test.dart
git commit -m "feat: add DiaryRepository with deterministic regroup and manual move/split/merge"
```

---

### Task 9: GoalsRepository

> **Confirmed against spec review**: the review asked whether switching from calculated to manual mode retains the profile inputs as a restorable baseline. Decision (see spec "Goals and BMR/TDEE calculation" > mode transition): no — `setManualGoals` deletes and replaces the single `Goals` row without carrying over `age`/`weightKg`/etc., matching the implementation below unchanged. Also confirmed: `Goals` has no per-day history (spec "Goals history") — no code change needed for either point, this task's implementation already matched the resolved decision.

**Files:**
- Create: `lib/data/goals_repository.dart`
- Test: `test/data/goals_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 2), `BmrInput`/`calculateGoals` (Task 4).
- Produces: `GoalsRepository` with `getGoals()`, `setManualGoals({required double dailyKcal, required double dailyProtein, required double dailyFat, required double dailyCarbs})`, `setCalculatedGoals(BmrInput input)`.

- [ ] **Step 1: Write the failing test**

Create `test/data/goals_repository_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/goals_repository.dart';
import 'package:callory/domain/bmr_calculator.dart';

void main() {
  late AppDatabase db;
  late GoalsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GoalsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('setManualGoals stores exactly the provided numbers in manual mode', () async {
    await repo.setManualGoals(
      dailyKcal: 2200,
      dailyProtein: 150,
      dailyFat: 70,
      dailyCarbs: 220,
    );

    final goals = await repo.getGoals();
    expect(goals, isNotNull);
    expect(goals!.mode, GoalsMode.manual);
    expect(goals.dailyKcal, 2200);
  });

  test('setCalculatedGoals derives numbers from BMR input and stores calculated mode', () async {
    const input = BmrInput(
      sex: Sex.male,
      age: 30,
      weightKg: 80,
      heightCm: 180,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
    );

    await repo.setCalculatedGoals(input);

    final goals = await repo.getGoals();
    expect(goals!.mode, GoalsMode.calculated);
    expect(goals.dailyKcal, closeTo(2759, 0.5));
    expect(goals.age, 30);
  });

  test('setting new goals replaces the previous single record', () async {
    await repo.setManualGoals(
      dailyKcal: 2000,
      dailyProtein: 100,
      dailyFat: 60,
      dailyCarbs: 200,
    );
    await repo.setManualGoals(
      dailyKcal: 2500,
      dailyProtein: 130,
      dailyFat: 80,
      dailyCarbs: 260,
    );

    final goals = await repo.getGoals();
    expect(goals!.dailyKcal, 2500);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/goals_repository_test.dart
```

Expected: FAIL — `GoalsRepository` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/data/goals_repository.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/bmr_calculator.dart';

class GoalsRepository {
  final AppDatabase db;
  GoalsRepository(this.db);

  Future<Goal?> getGoals() => (db.select(db.goals)..limit(1)).getSingleOrNull();

  Future<void> setManualGoals({
    required double dailyKcal,
    required double dailyProtein,
    required double dailyFat,
    required double dailyCarbs,
  }) async {
    await db.transaction(() async {
      await db.delete(db.goals).go();
      await db.into(db.goals).insert(GoalsCompanion.insert(
            dailyKcal: dailyKcal,
            dailyProtein: dailyProtein,
            dailyFat: dailyFat,
            dailyCarbs: dailyCarbs,
            mode: GoalsMode.manual,
          ));
    });
  }

  Future<void> setCalculatedGoals(BmrInput input) async {
    final result = calculateGoals(input);
    await db.transaction(() async {
      await db.delete(db.goals).go();
      await db.into(db.goals).insert(GoalsCompanion.insert(
            dailyKcal: result.kcal,
            dailyProtein: result.proteinG,
            dailyFat: result.fatG,
            dailyCarbs: result.carbsG,
            mode: GoalsMode.calculated,
            age: Value(input.age),
            weightKg: Value(input.weightKg),
            heightCm: Value(input.heightCm),
            sex: Value(input.sex.name),
            activityLevel: Value(input.activityLevel.name),
            goalType: Value(input.goalType.name),
          ));
    });
  }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/goals_repository_test.dart
```

Expected: PASS, all 3 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/data/goals_repository.dart test/data/goals_repository_test.dart
git commit -m "feat: add GoalsRepository for manual and calculated goals"
```

---

### Task 10: OpenFoodFactsSource

**Files:**
- Create: `lib/data/open_food_facts_source.dart`
- Test: `test/data/open_food_facts_source_test.dart`

**Interfaces:**
- Consumes: `FoodSource`/`FoodResult` (Task 6).
- Produces: `OpenFoodFactsSource implements FoodSource`, constructor `OpenFoodFactsSource({http.Client? client})`.

- [ ] **Step 1: Write the failing tests**

Create `test/data/open_food_facts_source_test.dart`:

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:callory/data/open_food_facts_source.dart';

void main() {
  test('searchByName parses a successful product list response', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), contains('search_terms=milk'));
      return http.Response(
        jsonEncode({
          'products': [
            {
              'product_name': 'Whole Milk',
              'code': '111',
              'nutriments': {
                'energy-kcal_100g': 61,
                'proteins_100g': 3.2,
                'fat_100g': 3.3,
                'carbohydrates_100g': 4.8,
              },
            },
          ],
        }),
        200,
      );
    });
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('milk');

    expect(results, hasLength(1));
    expect(results.first.name, 'Whole Milk');
    expect(results.first.kcalPer100g, 61);
    expect(results.first.existingPrivateFoodId, isNull);
  });

  test('searchByName returns an empty list on a non-200 response', () async {
    final client = MockClient((request) async => http.Response('error', 500));
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('anything');

    expect(results, isEmpty);
  });

  test('lookupBarcode returns null when the product is not found', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({'status': 0}),
          200,
        ));
    final source = OpenFoodFactsSource(client: client);

    final result = await source.lookupBarcode('0000000000000');

    expect(result, isNull);
  });

  test('lookupBarcode parses a found product', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Greek Yogurt',
              'code': '222',
              'nutriments': {
                'energy-kcal_100g': 90,
                'proteins_100g': 10,
                'fat_100g': 4,
                'carbohydrates_100g': 4,
              },
            },
          }),
          200,
        ));
    final source = OpenFoodFactsSource(client: client);

    final result = await source.lookupBarcode('222');

    expect(result, isNotNull);
    expect(result!.name, 'Greek Yogurt');
    expect(result.barcode, '222');
  });

  test('products missing nutriment data are skipped, not crashed on', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({
            'products': [
              {'product_name': 'No Nutrients Item', 'code': '333'},
            ],
          }),
          200,
        ));
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('anything');

    expect(results, isEmpty);
  });

  test('a network timeout degrades to an empty result instead of crashing', () async {
    final client = MockClient((request) async {
      throw TimeoutException('simulated network timeout');
    });
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('anything');
    final barcodeResult = await source.lookupBarcode('123');

    expect(results, isEmpty);
    expect(barcodeResult, isNull);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/open_food_facts_source_test.dart
```

Expected: FAIL — `OpenFoodFactsSource` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/data/open_food_facts_source.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:callory/domain/food_source.dart';

class OpenFoodFactsSource implements FoodSource {
  final http.Client client;
  OpenFoodFactsSource({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<List<FoodResult>> searchByName(String query) async {
    final uri = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl'
      '?search_terms=${Uri.encodeQueryComponent(query)}'
      '&search_simple=1&action=process&json=1&page_size=20',
    );
    try {
      final response = await client.get(uri);
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];
      return products
          .map((p) => _parseProduct(p as Map<String, dynamic>))
          .whereType<FoodResult>()
          .toList();
    } on Exception {
      return [];
    }
  }

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async {
    final uri =
        Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    try {
      final response = await client.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      return _parseProduct(data['product'] as Map<String, dynamic>);
    } on Exception {
      return null;
    }
  }

  FoodResult? _parseProduct(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>?;
    if (nutriments == null) return null;
    final kcal = _asDouble(nutriments['energy-kcal_100g']);
    final protein = _asDouble(nutriments['proteins_100g']);
    final fat = _asDouble(nutriments['fat_100g']);
    final carbs = _asDouble(nutriments['carbohydrates_100g']);
    if (kcal == null || protein == null || fat == null || carbs == null) {
      return null;
    }
    final name = product['product_name'] as String?;
    return FoodResult(
      name: (name != null && name.trim().isNotEmpty) ? name : 'Unknown',
      barcode: product['code'] as String?,
      kcalPer100g: kcal,
      proteinPer100g: protein,
      fatPer100g: fat,
      carbsPer100g: carbs,
    );
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/open_food_facts_source_test.dart
```

Expected: PASS, all 6 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/data/open_food_facts_source.dart test/data/open_food_facts_source_test.dart
git commit -m "feat: add keyless Open Food Facts source with graceful degradation"
```

---

### Task 11: FoodLookupService

**Files:**
- Create: `lib/data/food_lookup_service.dart`
- Test: `test/data/food_lookup_service_test.dart`

**Interfaces:**
- Consumes: `FoodSource`/`FoodResult` (Task 6), used generically so `FoodRepository` (Task 7) and `OpenFoodFactsSource` (Task 10) both plug in.
- Produces: `FoodLookupService` with `search(String query)`, `lookupBarcode(String barcode)`.

- [ ] **Step 1: Write the failing test**

Create `test/data/food_lookup_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/data/food_lookup_service.dart';

class _FakeSource implements FoodSource {
  final List<FoodResult> searchResults;
  final FoodResult? barcodeResult;
  _FakeSource({this.searchResults = const [], this.barcodeResult});

  @override
  Future<List<FoodResult>> searchByName(String query) async => searchResults;

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async => barcodeResult;
}

void main() {
  test('search merges private results before external results', () async {
    final private = _FakeSource(searchResults: [
      const FoodResult(
        name: 'My Yogurt',
        kcalPer100g: 90,
        proteinPer100g: 10,
        fatPer100g: 4,
        carbsPer100g: 4,
        existingPrivateFoodId: 1,
      ),
    ]);
    final external = _FakeSource(searchResults: [
      const FoodResult(
        name: 'Generic Yogurt',
        kcalPer100g: 80,
        proteinPer100g: 8,
        fatPer100g: 3,
        carbsPer100g: 5,
      ),
    ]);
    final service = FoodLookupService(private, external);

    final results = await service.search('yogurt');

    expect(results, hasLength(2));
    expect(results.first.name, 'My Yogurt');
    expect(results.last.name, 'Generic Yogurt');
  });

  test('lookupBarcode prefers the private match and skips the external call', () async {
    var externalCalled = false;
    final private = _FakeSource(
      barcodeResult: const FoodResult(
        name: 'My Bar',
        kcalPer100g: 200,
        proteinPer100g: 20,
        fatPer100g: 8,
        carbsPer100g: 15,
        existingPrivateFoodId: 5,
      ),
    );
    final external = _CallTrackingSource(onCalled: () => externalCalled = true);
    final service = FoodLookupService(private, external);

    final result = await service.lookupBarcode('123');

    expect(result!.existingPrivateFoodId, 5);
    expect(externalCalled, false);
  });

  test('lookupBarcode falls back to external when there is no private match', () async {
    final private = _FakeSource(barcodeResult: null);
    final external = _FakeSource(
      barcodeResult: const FoodResult(
        name: 'External Bar',
        kcalPer100g: 200,
        proteinPer100g: 20,
        fatPer100g: 8,
        carbsPer100g: 15,
      ),
    );
    final service = FoodLookupService(private, external);

    final result = await service.lookupBarcode('123');

    expect(result!.name, 'External Bar');
  });
}

class _CallTrackingSource implements FoodSource {
  final void Function() onCalled;
  _CallTrackingSource({required this.onCalled});

  @override
  Future<List<FoodResult>> searchByName(String query) async => [];

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async {
    onCalled();
    return null;
  }
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/food_lookup_service_test.dart
```

Expected: FAIL — `FoodLookupService` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/data/food_lookup_service.dart`:

```dart
import 'package:callory/domain/food_source.dart';

class FoodLookupService {
  final FoodSource privateSource;
  final FoodSource externalSource;
  FoodLookupService(this.privateSource, this.externalSource);

  Future<List<FoodResult>> search(String query) async {
    final privateResults = await privateSource.searchByName(query);
    final externalResults = await externalSource.searchByName(query);
    return [...privateResults, ...externalResults];
  }

  Future<FoodResult?> lookupBarcode(String barcode) async {
    final privateMatch = await privateSource.lookupBarcode(barcode);
    if (privateMatch != null) return privateMatch;
    return externalSource.lookupBarcode(barcode);
  }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/food_lookup_service_test.dart
```

Expected: PASS, all 3 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/data/food_lookup_service.dart test/data/food_lookup_service_test.dart
git commit -m "feat: add FoodLookupService combining private and external sources"
```

---

### Task 12: SettingsService (gap window)

**Files:**
- Create: `lib/data/settings_service.dart`
- Test: `test/data/settings_service_test.dart`

**Interfaces:**
- Produces: `SettingsService` with constructor `SettingsService(SharedPreferences prefs)`, getter `gapWindow` (`Duration`), `setGapWindowMinutes(int minutes)`, constant `SettingsService.defaultGapWindowMinutes`.

- [ ] **Step 1: Write the failing test**

Create `test/data/settings_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/data/settings_service.dart';

void main() {
  test('defaults to 90 minutes when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    expect(service.gapWindow, const Duration(minutes: 90));
  });

  test('setGapWindowMinutes persists and is reflected immediately', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    await service.setGapWindowMinutes(45);

    expect(service.gapWindow, const Duration(minutes: 45));
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/settings_service_test.dart
```

Expected: FAIL — `SettingsService` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/data/settings_service.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _gapWindowMinutesKey = 'gap_window_minutes';
  static const defaultGapWindowMinutes = 90;

  final SharedPreferences prefs;
  SettingsService(this.prefs);

  Duration get gapWindow =>
      Duration(minutes: prefs.getInt(_gapWindowMinutesKey) ?? defaultGapWindowMinutes);

  Future<void> setGapWindowMinutes(int minutes) =>
      prefs.setInt(_gapWindowMinutesKey, minutes);
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/settings_service_test.dart
```

Expected: PASS, both tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/data/settings_service.dart test/data/settings_service_test.dart
git commit -m "feat: add SettingsService for the configurable meal gap window"
```

---

### Task 13: ExportImportService

**Files:**
- Create: `lib/data/export_import_service.dart`
- Test: `test/data/export_import_service_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 2).
- Produces: `ExportImportService` with `exportToJson()` (`Future<Map<String, dynamic>>`), `importFromJson(Map<String, dynamic> json)`, constant `ExportImportService.formatVersion`.

- [ ] **Step 1: Write the failing test**

Create `test/data/export_import_service_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/export_import_service.dart';

void main() {
  test('export then import round-trips all four tables into a fresh database', () async {
    final sourceDb = AppDatabase.forTesting(NativeDatabase.memory());

    final foodId = await sourceDb.into(sourceDb.privateFoods).insert(
          PrivateFoodsCompanion.insert(
            name: 'Rice',
            kcalPer100g: 130,
            proteinPer100g: 3,
            fatPer100g: 0.3,
            carbsPer100g: 28,
            source: FoodSourceType.manual,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    final mealId = await sourceDb.into(sourceDb.meals).insert(
          MealsCompanion.insert(dayDate: DateTime(2026, 7, 14), mealNumber: 1),
        );
    await sourceDb.into(sourceDb.diaryEntries).insert(
          DiaryEntriesCompanion.insert(
            mealId: mealId,
            privateFoodId: Value(foodId),
            foodNameSnapshot: 'Rice',
            grams: 200,
            kcalSnapshot: 260,
            proteinSnapshot: 6,
            fatSnapshot: 0.6,
            carbsSnapshot: 56,
            occurredAt: DateTime(2026, 7, 14, 12, 0),
            createdAt: DateTime(2026, 7, 14, 12, 0),
            entryDate: DateTime(2026, 7, 14),
          ),
        );
    await sourceDb.into(sourceDb.goals).insert(
          GoalsCompanion.insert(
            dailyKcal: 2200,
            dailyProtein: 150,
            dailyFat: 70,
            dailyCarbs: 220,
            mode: GoalsMode.manual,
          ),
        );

    final exportService = ExportImportService(sourceDb);
    final json = await exportService.exportToJson();
    await sourceDb.close();

    final targetDb = AppDatabase.forTesting(NativeDatabase.memory());
    final importService = ExportImportService(targetDb);
    await importService.importFromJson(json);

    final foods = await targetDb.select(targetDb.privateFoods).get();
    final meals = await targetDb.select(targetDb.meals).get();
    final entries = await targetDb.select(targetDb.diaryEntries).get();
    final goals = await targetDb.select(targetDb.goals).get();

    expect(foods, hasLength(1));
    expect(foods.single.name, 'Rice');
    expect(meals, hasLength(1));
    expect(entries, hasLength(1));
    expect(entries.single.kcalSnapshot, 260);
    expect(goals, hasLength(1));
    expect(goals.single.dailyKcal, 2200);

    await targetDb.close();
  });

  test('importFromJson rejects an unknown format version', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = ExportImportService(db);

    expect(
      () => service.importFromJson({'formatVersion': 999}),
      throwsFormatException,
    );

    await db.close();
  });

  test('importFromJson fully replaces existing data rather than merging', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = ExportImportService(db);

    await db.into(db.privateFoods).insert(PrivateFoodsCompanion.insert(
          name: 'Old Food',
          kcalPer100g: 1,
          proteinPer100g: 1,
          fatPer100g: 1,
          carbsPer100g: 1,
          source: FoodSourceType.manual,
          createdAt: DateTime(2026, 1, 1),
        ));

    await service.importFromJson({
      'formatVersion': ExportImportService.formatVersion,
      'privateFoods': [],
      'meals': [],
      'diaryEntries': [],
      'goals': [],
    });

    final foods = await db.select(db.privateFoods).get();
    expect(foods, isEmpty);

    await db.close();
  });

  test('importFromJson rejects a missing formatVersion the same way as an unknown one', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = ExportImportService(db);

    expect(
      () => service.importFromJson({'privateFoods': [], 'meals': [], 'diaryEntries': [], 'goals': []}),
      throwsFormatException,
    );

    await db.close();
  });

  test('a structurally malformed field throws instead of silently corrupting data', () async {
    // The delete-then-insert sequence runs inside one Drift transaction, so
    // even though the malformed cast fails *after* the deletes have already
    // executed within that transaction, Drift rolls the whole thing back —
    // existing data survives untouched. See spec "Export/Import" > Atomicity.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = ExportImportService(db);

    await db.into(db.privateFoods).insert(PrivateFoodsCompanion.insert(
          name: 'Untouched Food',
          kcalPer100g: 1,
          proteinPer100g: 1,
          fatPer100g: 1,
          carbsPer100g: 1,
          source: FoodSourceType.manual,
          createdAt: DateTime(2026, 1, 1),
        ));

    await expectLater(
      service.importFromJson({
        'formatVersion': ExportImportService.formatVersion,
        'privateFoods': 'not-a-list', // malformed: should be a List
        'meals': [],
        'diaryEntries': [],
        'goals': [],
      }),
      throwsA(isA<TypeError>()),
    );

    final foods = await db.select(db.privateFoods).get();
    expect(foods, hasLength(1));
    expect(foods.single.name, 'Untouched Food');

    await db.close();
  });

  test('a referentially-invalid row is rejected and leaves existing data untouched', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = ExportImportService(db);

    await db.into(db.privateFoods).insert(PrivateFoodsCompanion.insert(
          name: 'Untouched Food',
          kcalPer100g: 1,
          proteinPer100g: 1,
          fatPer100g: 1,
          carbsPer100g: 1,
          source: FoodSourceType.manual,
          createdAt: DateTime(2026, 1, 1),
        ));

    await expectLater(
      service.importFromJson({
        'formatVersion': ExportImportService.formatVersion,
        'privateFoods': [],
        'meals': [], // note: no meal with id 999 defined below
        'diaryEntries': [
          {
            'id': 1,
            'mealId': 999,
            'privateFoodId': null,
            'foodNameSnapshot': 'Ghost Entry',
            'grams': 100.0,
            'kcalSnapshot': 1.0,
            'proteinSnapshot': 1.0,
            'fatSnapshot': 1.0,
            'carbsSnapshot': 1.0,
            'occurredAt': DateTime(2026, 7, 14).toIso8601String(),
            'createdAt': DateTime(2026, 7, 14).toIso8601String(),
            'updatedAt': null,
            'entryDate': DateTime(2026, 7, 14).toIso8601String(),
          }
        ],
        'goals': [],
      }),
      throwsA(isA<Exception>()), // SQLite FK violation, since PRAGMA foreign_keys = ON (Task 2)
    );

    final foods = await db.select(db.privateFoods).get();
    expect(foods, hasLength(1));
    expect(foods.single.name, 'Untouched Food');

    await db.close();
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/export_import_service_test.dart
```

Expected: FAIL — `ExportImportService` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/data/export_import_service.dart`:

```dart
import 'package:callory/db/database.dart';

class ExportImportService {
  static const formatVersion = 1;

  final AppDatabase db;
  ExportImportService(this.db);

  Future<Map<String, dynamic>> exportToJson() async {
    final foods = await db.select(db.privateFoods).get();
    final meals = await db.select(db.meals).get();
    final entries = await db.select(db.diaryEntries).get();
    final goals = await db.select(db.goals).get();

    return {
      'formatVersion': formatVersion,
      'privateFoods': foods.map((f) => f.toJson()).toList(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'diaryEntries': entries.map((e) => e.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
    };
  }

  Future<void> importFromJson(Map<String, dynamic> json) async {
    if (json['formatVersion'] != formatVersion) {
      throw FormatException(
        'Unsupported export format version: ${json['formatVersion']}',
      );
    }

    await db.transaction(() async {
      await db.delete(db.diaryEntries).go();
      await db.delete(db.meals).go();
      await db.delete(db.privateFoods).go();
      await db.delete(db.goals).go();

      for (final row in (json['privateFoods'] as List)) {
        final food = PrivateFood.fromJson(row as Map<String, dynamic>);
        await db.into(db.privateFoods).insert(food.toCompanion(true));
      }
      for (final row in (json['meals'] as List)) {
        final meal = Meal.fromJson(row as Map<String, dynamic>);
        await db.into(db.meals).insert(meal.toCompanion(true));
      }
      for (final row in (json['diaryEntries'] as List)) {
        final entry = DiaryEntry.fromJson(row as Map<String, dynamic>);
        await db.into(db.diaryEntries).insert(entry.toCompanion(true));
      }
      for (final row in (json['goals'] as List)) {
        final goal = Goal.fromJson(row as Map<String, dynamic>);
        await db.into(db.goals).insert(goal.toCompanion(true));
      }
    });
  }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/export_import_service_test.dart
```

Expected: PASS, all 6 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/data/export_import_service.dart test/data/export_import_service_test.dart
git commit -m "feat: add JSON export/import with full-replace semantics"
```

---

### Task 14: Riverpod providers

**Files:**
- Create: `lib/providers/providers.dart`
- Test: `test/data/providers_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 2), `FoodRepository` (Task 7), `DiaryRepository` (Task 8), `GoalsRepository` (Task 9), `OpenFoodFactsSource` (Task 10), `FoodLookupService` (Task 11), `SettingsService` (Task 12), `ExportImportService` (Task 13).
- Produces: `databaseProvider`, `foodRepositoryProvider`, `diaryRepositoryProvider`, `goalsRepositoryProvider`, `foodLookupServiceProvider`, `exportImportServiceProvider`, `settingsServiceProvider` (an `override`-able `Provider<SettingsService>` that throws if not overridden — it needs an async-initialized `SharedPreferences` instance supplied at app startup), `selectedDayProvider` (`StateProvider<DateTime>`, defaults to today).

- [ ] **Step 1: Write the failing test**

Create `test/data/providers_test.dart`:

```dart
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
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/data/providers_test.dart
```

Expected: FAIL — `lib/providers/providers.dart` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/providers/providers.dart`:

```dart
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
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/data/providers_test.dart
```

Expected: PASS, both tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/providers/providers.dart test/data/providers_test.dart
git commit -m "feat: wire Riverpod providers for repositories and services"
```

---

### Task 15: Day screen

**Files:**
- Create: `lib/ui/day/day_screen.dart`
- Test: `test/ui/day_screen_test.dart`

**Interfaces:**
- Consumes: `diaryRepositoryProvider`, `goalsRepositoryProvider`, `selectedDayProvider` (Task 14), `DiaryEntry`/`Meal` (Task 2).
- Produces: `DayScreen` widget (`ConsumerWidget`), shown as the app's home screen.

- [ ] **Step 1: Write the failing test**

Create `test/ui/day_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/db/database.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/day/day_screen.dart';

void main() {
  testWidgets('shows an empty state with no meals logged for the day', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: const MaterialApp(home: DayScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No meals logged yet'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows a logged entry grouped under its meal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final diaryRepo = DiaryRepositoryForTest(db);
    final today = DateTime.now();
    await diaryRepo.addEntry(
      foodNameSnapshot: 'Test Meal Item',
      grams: 100,
      kcalPer100g: 150,
      proteinPer100g: 10,
      fatPer100g: 5,
      carbsPer100g: 10,
      entryDate: DateTime(today.year, today.month, today.day),
      occurredAt: today,
      gapWindow: const Duration(minutes: 90),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
      child: const MaterialApp(home: DayScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Test Meal Item'), findsOneWidget);
    expect(find.textContaining('Прием 1'), findsOneWidget);

    await db.close();
  });
}
```

Add a tiny re-export alias so the test doesn't need to import the repository under a different name than production code — actually just import `DiaryRepository` directly instead of `DiaryRepositoryForTest`. Fix the test file to use:

```dart
import 'package:callory/data/diary_repository.dart';
```

and replace `DiaryRepositoryForTest(db)` with `DiaryRepository(db)`.

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/ui/day_screen_test.dart
```

Expected: FAIL — `lib/ui/day/day_screen.dart` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/ui/day/day_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callory/db/database.dart';
import 'package:callory/providers/providers.dart';

class DayScreen extends ConsumerWidget {
  const DayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final diaryRepo = ref.watch(diaryRepositoryProvider);
    final goalsRepo = ref.watch(goalsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(selectedDay)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => ref.read(selectedDayProvider.notifier).state =
              selectedDay.subtract(const Duration(days: 1)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedDayProvider.notifier).state =
                selectedDay.add(const Duration(days: 1)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: (
          diaryRepo.getMealsForDate(selectedDay),
          diaryRepo.getEntriesForDate(selectedDay),
          goalsRepo.getGoals(),
        ).$1.then((meals) async => (
              meals,
              await diaryRepo.getEntriesForDate(selectedDay),
              await goalsRepo.getGoals(),
            )),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (meals, entries, goals) = snapshot.data!;

          if (meals.isEmpty) {
            return const Center(child: Text('No meals logged yet'));
          }

          final totals = _sumTotals(entries);

          // Manual meal numbers aren't chronologically meaningful (a manual
          // meal created late in the day can carry a low or high number
          // independent of when its entries actually occurred) — display
          // order is by each meal's earliest entry time, not meal_number,
          // per spec "Meal grouping algorithm" > Display ordering.
          final sortedMeals = [...meals]..sort((a, b) {
              final aTime = entries
                  .where((e) => e.mealId == a.id)
                  .map((e) => e.occurredAt)
                  .reduce((x, y) => x.isBefore(y) ? x : y);
              final bTime = entries
                  .where((e) => e.mealId == b.id)
                  .map((e) => e.occurredAt)
                  .reduce((x, y) => x.isBefore(y) ? x : y);
              return aTime.compareTo(bTime);
            });

          return Column(
            children: [
              if (goals != null) _GoalProgress(totals: totals, goals: goals),
              Expanded(
                child: ListView(
                  children: sortedMeals
                      .map((meal) => _MealSection(
                            meal: meal,
                            entries: entries.where((e) => e.mealId == meal.id).toList(),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ({double kcal, double protein, double fat, double carbs}) _sumTotals(
    List<DiaryEntry> entries,
  ) {
    var kcal = 0.0, protein = 0.0, fat = 0.0, carbs = 0.0;
    for (final e in entries) {
      kcal += e.kcalSnapshot;
      protein += e.proteinSnapshot;
      fat += e.fatSnapshot;
      carbs += e.carbsSnapshot;
    }
    return (kcal: kcal, protein: protein, fat: fat, carbs: carbs);
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _GoalProgress extends StatelessWidget {
  final ({double kcal, double protein, double fat, double carbs}) totals;
  final Goal goals;
  const _GoalProgress({required this.totals, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _ProgressRow(label: 'Kcal', actual: totals.kcal, goal: goals.dailyKcal),
          _ProgressRow(label: 'Protein', actual: totals.protein, goal: goals.dailyProtein),
          _ProgressRow(label: 'Fat', actual: totals.fat, goal: goals.dailyFat),
          _ProgressRow(label: 'Carbs', actual: totals.carbs, goal: goals.dailyCarbs),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double actual;
  final double goal;
  const _ProgressRow({required this.label, required this.actual, required this.goal});

  @override
  Widget build(BuildContext context) {
    final ratio = goal <= 0 ? 0.0 : (actual / goal).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label)),
          Expanded(child: LinearProgressIndicator(value: ratio)),
          const SizedBox(width: 8),
          Text('${actual.round()}/${goal.round()}'),
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final Meal meal;
  final List<DiaryEntry> entries;
  const _MealSection({required this.meal, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Прием ${meal.mealNumber}', style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final entry in entries)
          ListTile(
            title: Text(entry.foodNameSnapshot),
            subtitle: Text('${entry.grams.round()} g'),
            trailing: Text('${entry.kcalSnapshot.round()} kcal'),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/ui/day_screen_test.dart
```

Expected: PASS, both tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/day/day_screen.dart test/ui/day_screen_test.dart
git commit -m "feat: add day screen with meal grouping and goal progress"
```

---

### Task 16: Add Food screen

**Files:**
- Create: `lib/ui/add_food/add_food_screen.dart`

**Interfaces:**
- Consumes: `foodLookupServiceProvider`, `foodRepositoryProvider`, `diaryRepositoryProvider`, `settingsServiceProvider`, `selectedDayProvider` (Task 14), `FoodResult` (Task 6).
- Produces: `AddFoodScreen` widget with three tabs (search, barcode, manual). No dedicated widget test — this screen is primarily wiring over already-tested repositories/services (Tasks 7-14); it is exercised via the manual smoke test in Task 19.

- [ ] **Step 1: Implement**

Create `lib/ui/add_food/add_food_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/providers/providers.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add food'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Barcode'),
            Tab(text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SearchTab(),
          _BarcodeTab(),
          _ManualTab(),
        ],
      ),
    );
  }
}

class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab();

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _controller = TextEditingController();
  List<FoodResult> _results = [];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final results = await ref.read(foodLookupServiceProvider).search(query);
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Search foods'),
            onSubmitted: _search,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              return ListTile(
                title: Text(result.name),
                subtitle: Text(
                  '${result.kcalPer100g.round()} kcal / 100g'
                  '${result.existingPrivateFoodId == null ? '' : ' (in your foods)'}',
                ),
                onTap: () => _openGramsDialog(context, result),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openGramsDialog(BuildContext context, FoodResult result) async {
    await showEditableFoodDialog(context: context, ref: ref, initial: result);
  }
}

class _BarcodeTab extends ConsumerWidget {
  const _BarcodeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileScanner(
      onDetect: (capture) async {
        final barcode = capture.barcodes.firstOrNull?.rawValue;
        if (barcode == null) return;
        final result = await ref.read(foodLookupServiceProvider).lookupBarcode(barcode);
        if (!context.mounted) return;
        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found — enter it manually')),
          );
          return;
        }
        await showEditableFoodDialog(
          context: context,
          ref: ref,
          initial: result,
          barcode: barcode,
        );
      },
    );
  }
}

class _ManualTab extends ConsumerWidget {
  const _ManualTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () => showEditableFoodDialog(
          context: context,
          ref: ref,
          initial: const FoodResult(
            name: '',
            kcalPer100g: 0,
            proteinPer100g: 0,
            fatPer100g: 0,
            carbsPer100g: 0,
          ),
        ),
        child: const Text('Add food manually'),
      ),
    );
  }
}

/// Shows an editable card for a [FoodResult] (from barcode lookup, external
/// search, or a blank manual entry), lets the user adjust fields and grams,
/// saves it to the private food database, and logs a diary entry for it.
Future<void> showEditableFoodDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FoodResult initial,
  String? barcode,
}) async {
  final nameController = TextEditingController(text: initial.name);
  final kcalController = TextEditingController(text: initial.kcalPer100g.toString());
  final proteinController = TextEditingController(text: initial.proteinPer100g.toString());
  final fatController = TextEditingController(text: initial.fatPer100g.toString());
  final carbsController = TextEditingController(text: initial.carbsPer100g.toString());
  final gramsController = TextEditingController(text: '100');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Food details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: kcalController, decoration: const InputDecoration(labelText: 'Kcal / 100g'), keyboardType: TextInputType.number),
            TextField(controller: proteinController, decoration: const InputDecoration(labelText: 'Protein / 100g'), keyboardType: TextInputType.number),
            TextField(controller: fatController, decoration: const InputDecoration(labelText: 'Fat / 100g'), keyboardType: TextInputType.number),
            TextField(controller: carbsController, decoration: const InputDecoration(labelText: 'Carbs / 100g'), keyboardType: TextInputType.number),
            TextField(controller: gramsController, decoration: const InputDecoration(labelText: 'Grams eaten'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
      ],
    ),
  );

  if (confirmed != true) return;

  final kcalPer100g = double.tryParse(kcalController.text) ?? 0;
  final proteinPer100g = double.tryParse(proteinController.text) ?? 0;
  final fatPer100g = double.tryParse(fatController.text) ?? 0;
  final carbsPer100g = double.tryParse(carbsController.text) ?? 0;
  final grams = double.tryParse(gramsController.text) ?? 100;

  final foodRepo = ref.read(foodRepositoryProvider);
  final source = initial.existingPrivateFoodId != null
      ? null // already private, no need to re-insert
      : (barcode != null ? FoodSourceType.barcode : (initial.name.isEmpty ? FoodSourceType.manual : FoodSourceType.copiedExternal));

  final privateFoodId = initial.existingPrivateFoodId ??
      await foodRepo.insertFood(
        name: nameController.text,
        barcode: barcode,
        kcalPer100g: kcalPer100g,
        proteinPer100g: proteinPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        source: source!,
      );

  final settings = ref.read(settingsServiceProvider);
  final selectedDay = ref.read(selectedDayProvider);
  await ref.read(diaryRepositoryProvider).addEntry(
        privateFoodId: privateFoodId,
        foodNameSnapshot: nameController.text,
        grams: grams,
        kcalPer100g: kcalPer100g,
        proteinPer100g: proteinPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        entryDate: selectedDay,
        occurredAt: DateTime.now(),
        gapWindow: settings.gapWindow,
      );
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/ui/add_food/add_food_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/add_food/add_food_screen.dart
git commit -m "feat: add Add Food screen with search, barcode and manual tabs"
```

---

### Task 17: Goals screen

**Files:**
- Create: `lib/ui/goals/goals_screen.dart`
- Test: `test/ui/goals_screen_test.dart`

**Interfaces:**
- Consumes: `goalsRepositoryProvider` (Task 14), `BmrInput`/`Sex`/`ActivityLevel`/`GoalType` (Task 4).
- Produces: `GoalsScreen` widget with a manual/calculated mode toggle.

- [ ] **Step 1: Write the failing test**

Create `test/ui/goals_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:callory/db/database.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/goals/goals_screen.dart';

void main() {
  testWidgets('manual mode lets the user type kcal directly and save it', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    // Manual mode is the default; enter a kcal value and save.
    await tester.enterText(find.byKey(const Key('manualKcalField')), '2200');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    final goals = await db.select(db.goals).getSingleOrNull();
    expect(goals, isNotNull);
    expect(goals!.dailyKcal, 2200);
    expect(goals.mode, GoalsMode.manual);

    await db.close();
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/ui/goals_screen_test.dart
```

Expected: FAIL — `lib/ui/goals/goals_screen.dart` doesn't exist.

- [ ] **Step 3: Implement**

Create `lib/ui/goals/goals_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callory/domain/bmr_calculator.dart';
import 'package:callory/providers/providers.dart';

enum _Mode { manual, calculated }

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  _Mode _mode = _Mode.manual;

  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  Sex _sex = Sex.male;
  ActivityLevel _activityLevel = ActivityLevel.sedentary;
  GoalType _goalType = GoalType.maintain;

  Future<void> _save() async {
    final goalsRepo = ref.read(goalsRepositoryProvider);
    if (_mode == _Mode.manual) {
      await goalsRepo.setManualGoals(
        dailyKcal: double.tryParse(_kcalController.text) ?? 0,
        dailyProtein: double.tryParse(_proteinController.text) ?? 0,
        dailyFat: double.tryParse(_fatController.text) ?? 0,
        dailyCarbs: double.tryParse(_carbsController.text) ?? 0,
      );
    } else {
      await goalsRepo.setCalculatedGoals(BmrInput(
        sex: _sex,
        age: int.tryParse(_ageController.text) ?? 0,
        weightKg: double.tryParse(_weightController.text) ?? 0,
        heightCm: double.tryParse(_heightController.text) ?? 0,
        activityLevel: _activityLevel,
        goalType: _goalType,
      ));
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_Mode>(
            segments: const [
              ButtonSegment(value: _Mode.manual, label: Text('Manual')),
              ButtonSegment(value: _Mode.calculated, label: Text('Calculated')),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => setState(() => _mode = selection.first),
          ),
          const SizedBox(height: 16),
          if (_mode == _Mode.manual) ...[
            TextField(
              key: const Key('manualKcalField'),
              controller: _kcalController,
              decoration: const InputDecoration(labelText: 'Daily kcal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _proteinController,
              decoration: const InputDecoration(labelText: 'Protein (g)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _fatController,
              decoration: const InputDecoration(labelText: 'Fat (g)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _carbsController,
              decoration: const InputDecoration(labelText: 'Carbs (g)'),
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            DropdownButton<Sex>(
              value: _sex,
              items: Sex.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (value) => setState(() => _sex = value!),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<ActivityLevel>(
              value: _activityLevel,
              items: ActivityLevel.values.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
              onChanged: (value) => setState(() => _activityLevel = value!),
            ),
            DropdownButton<GoalType>(
              value: _goalType,
              items: GoalType.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
              onChanged: (value) => setState(() => _goalType = value!),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('saveGoalsButton'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
flutter test test/ui/goals_screen_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/goals/goals_screen.dart test/ui/goals_screen_test.dart
git commit -m "feat: add Goals screen with manual and calculated modes"
```

---

### Task 18: Settings screen (gap window + export/import)

**Files:**
- Create: `lib/ui/settings/settings_screen.dart`

**Interfaces:**
- Consumes: `settingsServiceProvider`, `exportImportServiceProvider` (Task 14), `file_picker`, `share_plus`.
- Produces: `SettingsScreen` widget. No dedicated widget test — file-picker/share-sheet interaction is platform-native and isn't meaningfully testable in the widget test harness; it's covered by the manual smoke test in Task 19.

- [ ] **Step 1: Implement**

Create `lib/ui/settings/settings_screen.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:callory/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _gapMinutes;

  @override
  void initState() {
    super.initState();
    _gapMinutes = ref.read(settingsServiceProvider).gapWindow.inMinutes;
  }

  Future<void> _exportData() async {
    final json = await ref.read(exportImportServiceProvider).exportToJson();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/callory_export.json');
    await file.writeAsString(jsonEncode(json));
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<void> _importData() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace current data?'),
        content: const Text('Importing will overwrite all current data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Replace')),
        ],
      ),
    );
    if (confirmed != true) return;

    final content = await File(path).readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    await ref.read(exportImportServiceProvider).importFromJson(json);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Meal grouping gap: $_gapMinutes minutes'),
          Slider(
            value: _gapMinutes.toDouble(),
            min: 15,
            max: 240,
            divisions: 15,
            label: '$_gapMinutes min',
            onChanged: (value) => setState(() => _gapMinutes = value.round()),
            onChangeEnd: (value) =>
                ref.read(settingsServiceProvider).setGapWindowMinutes(value.round()),
          ),
          const Divider(height: 32),
          ElevatedButton(onPressed: _exportData, child: const Text('Export data (JSON)')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _importData, child: const Text('Import data (JSON)')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/ui/settings/settings_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/settings/settings_screen.dart
git commit -m "feat: add Settings screen with gap window and JSON export/import"
```

---

### Task 19: App shell wiring and manual smoke test

**Files:**
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `DayScreen` (Task 15), `AddFoodScreen` (Task 16), `GoalsScreen` (Task 17), `SettingsScreen` (Task 18), `settingsServiceProvider` (Task 14).
- Produces: the runnable app entry point.

- [ ] **Step 1: Replace `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/ui/day/day_screen.dart';
import 'package:callory/ui/add_food/add_food_screen.dart';
import 'package:callory/ui/goals/goals_screen.dart';
import 'package:callory/ui/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ],
    child: const CalloryApp(),
  ));
}

class CalloryApp extends StatelessWidget {
  const CalloryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Callory',
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  static const _screens = [
    DayScreen(),
    AddFoodScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Day'),
          NavigationDestination(icon: Icon(Icons.add), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

Delete the old default counter-app widget test since it references removed code:

```bash
rm test/widget_test.dart
```

- [ ] **Step 2: Run the full test suite**

```bash
flutter test
```

Expected: PASS — every test written in Tasks 3–17 is green, nothing references the deleted counter-app test.

- [ ] **Step 3: Manual smoke test**

```bash
flutter run
```

On a connected device or emulator, verify by hand:
1. App opens to the Day screen showing "No meals logged yet".
2. Tap "Add" → Manual tab → fill in a food (e.g. name "Test Apple", kcal 52, protein 0.3, fat 0.2, carbs 14, grams 150) → Save.
3. Return to Day screen (tap "Day") → confirm the entry appears under "Прием 1" with rescaled totals shown in the goal progress bar area once goals are set.
4. Go to Goals → enter manual kcal 2000 and macros → Save → return to Day → confirm the progress bars now show actual/goal.
5. Go to Settings → Export data → confirm a share sheet opens with a `callory_export.json` file.
6. Go to Add → Barcode tab → point camera at any barcode → confirm it either finds a product or shows "Product not found — enter it manually" (requires network; if offline, confirm it degrades gracefully instead of crashing).

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git rm test/widget_test.dart
git commit -m "feat: wire app shell navigation across Day, Add, Goals, Settings"
```

---

## Self-Review Notes

**Spec coverage:** every spec section maps to at least one task — architecture/layering (Tasks 1, 2, 14), data model incl. `occurred_at`/`created_at`/`updated_at` and `ON DELETE SET NULL` (Task 2), nutrition snapshotting (Tasks 8, 9 tests), the deterministic meal grouping algorithm and manual-lock invariants incl. move/split/merge (Tasks 3, 8), entry editing/rescale (Tasks 5, 8), food sources incl. FatSecret exclusion and the `FoodResult` contract (Tasks 6, 7, 10, 11), goals/BMR with locked constants and the no-history/discard-on-override decisions (Tasks 4, 9, 17), export/import full-replace with atomicity and bad-data tests (Task 13), UI day view with chronological meal display ordering (Task 15), gap-window setting (Tasks 12, 18), testing strategy (unit/repository/widget/mocked-HTTP tests present in every relevant task, extended per the spec review's "Testing" additions).

**Placeholder scan:** no TBD/TODO markers; every step has runnable commands and complete code.

**Type consistency:** `FoodResult`, `FoodSource`, `AutoEntry`, `MealCluster`, `NutrientSnapshot`, `BmrInput`, `MacroGoals` are defined once (Tasks 3, 4, 5, 6) and reused with identical field names throughout Tasks 7–18. (`MealSummary`/`MealGroupingResult` from the pre-review draft of Task 3 no longer exist — superseded by `AutoEntry`/`MealCluster`.)

**Post-review revision scan:** no remaining references to the old `logged_at` field name, `assignMeal`, `reassignEntryToMeal`, or `updateEntryLoggedAt` — all call sites (Tasks 8, 13, 15, 16) were updated to `occurred_at`/`clusterAutoEntries`/`moveEntryToMeal`/`updateEntryOccurredAt`.
