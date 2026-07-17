# Meal Header Totals — Design

## Problem
Day screen (`lib/ui/day/day_screen.dart`) groups entries into meals via `_MealSection`, an `ExpansionTile` titled only `Meal N` (via `loc.dayMealSection(meal.mealNumber)`). To see a meal's total kcal/macros, the user must expand it and add up each entry by eye.

## Solution
Inline the meal's summed kcal and P/F/C into the section title itself, so totals are visible whether the section is expanded or collapsed.

### Format
`Meal 1 — 300 kcal, 20/10/20`

- `Meal 1` — existing `loc.dayMealSection(meal.mealNumber)`.
- ` — ` — em dash separator (hardcoded punctuation, not localized — matches existing hardcoded punctuation like the `/` in per-entry macro lines).
- `300 kcal` — existing `loc.dayEntryKcal(kcal.round())` locale string, reused as-is.
- `20/10/20` — rounded protein/fat/carbs numbers, comma-separated from kcal, no `P/F/C` label (dropped per feedback — numbers only).

### Implementation
`DayScreen` already has an instance method `_sumTotals(List<DiaryEntry>)` that sums kcal/protein/fat/carbs for the whole day. Extract this into a shared top-level function in `day_screen.dart`:

```dart
({double kcal, double protein, double fat, double carbs}) _sumEntryTotals(
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
```

- `DayScreen.build` calls `_sumEntryTotals(entries)` for the whole-day totals (replacing the old instance-method call).
- `_MealSection.build` calls `_sumEntryTotals(entries)` on its own (already meal-scoped) `entries` list, then builds the title:

```dart
title: Text(
  '${loc.dayMealSection(meal.mealNumber)} — ${loc.dayEntryKcal(totals.kcal.round())}, '
  '${totals.protein.round()}/${totals.fat.round()}/${totals.carbs.round()}',
  style: Theme.of(context).textTheme.titleMedium,
),
```

No new localization keys — reuses `dayEntryKcal`.

## Out of scope
- No changes to whole-day totals display (`_GoalProgress`/`_ProgressRow`) beyond the internal refactor to share `_sumEntryTotals`.
- No changes to per-entry rows inside the expanded meal section.
- No new l10n strings.

## Testing
- Widget test: a meal with two entries (e.g. 150 kcal/10P/5F/10C each) shows `Meal 1 — 300 kcal, 20/10/20` in the section title, both collapsed and expanded.
- Existing whole-day totals tests continue to pass unchanged (regression check on the `_sumEntryTotals` extraction).
