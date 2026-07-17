# Manual tab redesign — design spec

## Problem

The "Manual" tab in `AddFoodScreen` is currently a single centered button. Tapping
it opens the same full editable dialog used by Recent/Search/Barcode — name, all
four nutrients, grams eaten, favorite — and every save both creates/updates the
food *and* logs a diary entry for today. There is no way to browse products the
user already created, and no lightweight way to log an already-known product
without re-typing its nutrition.

## Goal

Split the tab into two distinct actions, matching how the user actually thinks
about it:

1. **Add a new product** — define name + nutrition once, into the library. Does
   not log anything eaten today.
2. **Log an already-known product** — pick from the full list of previously
   added products, enter only the grams eaten. Nutrition fields are read-only
   (not editable from this flow).

Recent/Search/Barcode tabs and their existing dialog (`showEditableFoodDialog`,
which still both edits nutrition *and* logs an entry) are unchanged — this
redesign is scoped to the Manual tab only.

## Architecture

New file `lib/ui/add_food/manual_tab.dart` holds the redesigned `_ManualTab`
(now stateful) plus its two new dialog functions. `add_food_screen.dart` keeps
`showEditableFoodDialog` and `_logEntry` as-is for the other three tabs, and
imports `_ManualTab` from the new file in its `TabBarView`.

Rationale: `add_food_screen.dart` is already 574 lines covering four tabs plus
a shared dialog. The Manual tab is gaining its own state (search text, list,
two dialogs) — giving it a dedicated file keeps each tab's file focused and
avoids growing the shared file further.

### Repository

Add `FoodRepository.getAllFoods()`:

```dart
Future<List<FoodResult>> getAllFoods() async {
  final rows = await (db.select(db.privateFoods)
        ..orderBy([(f) => OrderingTerm.asc(f.name)]))
      .get();
  return rows.map(_toResult).toList();
}
```

Returns every row in `private_foods`, ordered alphabetically by name — not
filtered to foods that have a diary entry (unlike `getRecentFoods`).

## Components

### 1. `_ManualTab` (stateful, replaces the current stateless button-only widget)

Layout, top to bottom:

- "Add product" button (`ElevatedButton`, label `addFoodAddProductButton`) →
  opens the **Add-Product dialog**.
- Search `TextField` (label `addFoodSearchLabel`, reused) — filters the
  already-loaded list client-side by case-insensitive substring match on name.
  No repo round-trip per keystroke.
- `ListView.builder` over the filtered list. Each row: name + kcal/100g
  subtitle (`addFoodKcalPer100g`, reused), trailing star icon toggling
  favorite (same pattern as `_RecentTabState._toggleFavorite` —
  `foodRepo.setFavorite(id, !isFavorite)` then refetch). `onTap` → opens the
  **Log-Existing dialog** for that food.
- Empty state: if `getAllFoods()` returns nothing, show
  `addFoodNoProductsYet` centered instead of the list.

State: `late Future<List<FoodResult>> _allFoods` (fetched in `initState`, redone
via `_refresh()` after add/toggle/log — same shape as `_RecentTabState`), plus
a `String _query` for the search box driving the client-side filter.

### 2. Add-Product dialog — `showAddProductDialog`

Fields: name, kcal/100g, protein/100g, fat/100g, carbs/100g (all
`NumberField`/`TextField`, same widgets as the existing dialog), favorite
checkbox. **No grams field.**

Validation: nutrient values must be non-negative finite numbers
(`addFoodNutrientError`, reused) — same check as today, minus the grams check
(there is no grams field to check).

On save: always a fresh `foodRepo.insertFood(..., source: FoodSourceType.manual,
barcode: null)`. This dialog only ever creates — there is no barcode-based
dedupe/update path here, unlike `showEditableFoodDialog`. Does **not** call
`_logEntry`. Dialog title: `addFoodAddProductDialogTitle`.

### 3. Log-Existing dialog — `showLogExistingFoodDialog(food: FoodResult)`

Read-only header: food name (title) + a plain `Text` line with its per-100g
kcal/protein/fat/carbs (not editable fields — no `TextField`/`NumberField` for
nutrition in this dialog). One `NumberField` for grams eaten (label
`addFoodGramsEatenLabel`, reused, default `'100'`).

Validation: grams must be a positive finite number (`addFoodGramsError`,
reused).

On save: calls the existing `_logEntry` helper with `food.existingPrivateFoodId`
and the food's stored (unmodified) nutrient values — no `updateFood` call, no
favorite toggle from this dialog.

## Data flow / errors

- `getAllFoods()` loads once per tab-build/refresh, same `FutureBuilder` +
  `_refresh()` pattern as `_RecentTab`.
- Search is purely client-side over the loaded list.
- Both new dialogs reuse existing error copy (`addFoodNutrientError`,
  `addFoodGramsError`) — no new error strings.
- New l10n keys needed (en + ru): `addFoodAddProductButton`,
  `addFoodAddProductDialogTitle`, `addFoodNoProductsYet`. Everything else
  (name/kcal/protein/fat/carbs labels, save/cancel, grams-eaten label,
  kcal-per-100g format, search label) is reused from the existing `addFood*`
  keys.

## Testing

New `test/ui/manual_tab_test.dart` (mirrors patterns in
`test/ui/add_food_screen_test.dart`):

- Adding a product via the Add-Product dialog makes it appear in the list
  below, without creating a diary entry.
- Tapping a list item opens the Log-Existing dialog; it shows no editable
  nutrition fields, only a grams field; saving logs a diary entry with the
  food's existing nutrition values unchanged.
- The search field filters the list to matching names only.
- Tapping the star toggles favorite and persists across refresh.

## Out of scope

- Editing an existing product's nutrition from the Manual tab (still only
  reachable via Recent/Search's `showEditableFoodDialog`).
- Deleting a product from the library.
- A favorites-only filter switch on the Manual tab (the per-row star toggle is
  in scope; a separate switch like Recent tab's is not).
