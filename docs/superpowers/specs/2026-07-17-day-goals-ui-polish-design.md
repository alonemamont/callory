# Day & Goals screen UI polish

Date: 2026-07-17
Status: Approved

## Context

Five small, related UX fixes on `DayScreen` and `GoalsScreen`:

1. Meal sections should collapse/expand (accordion) on header tap. All but the most recent meal collapsed by default when the day screen opens.
2. Meals should sort newest-first (current meal always on top).
3. The Russian "Carbs" progress label ("Углеводы") doesn't fit its 70px column; needs shortening.
4. Individual diary entries should show calories in a larger font, with a macro breakdown line ("P/F/C" grams) beneath.
5. The Sex / Activity Level / Goal Type dropdowns in "Calculated" goals mode show no field label and no explanation of what each option means. Replace with a tap-to-open picker that shows a field label + current value, and a modal listing each option with an explanation.

All five are scoped to `lib/ui/day/day_screen.dart`, `lib/ui/goals/goals_screen.dart`, and the `lib/l10n/*.arb` files. Treated as one spec since they're small, independent-but-adjacent tweaks to the same two screens rather than separate subsystems.

## 1. Meal accordion + newest-first sort

`meal.mealNumber` is assigned sequentially as meals are created during the day (`diary_repository.dart:145`, `getMealsForDate` currently returns them ascending by `mealNumber`). Highest `mealNumber` = most recently created meal.

- `DayScreen` displays `meals.reversed` instead of `meals` (repository query stays ascending — only the UI list order changes). This puts the newest meal first.
- `_MealSection` becomes a widget wrapping Flutter's `ExpansionTile`: header = existing `Text(loc.dayMealSection(...))`, children = the existing entry `ListTile`s.
- `DayScreen` passes `initiallyExpanded: isLatest` where `isLatest` is true only for the first item in the reversed list (index 0). This is per-build local widget state (`ExpansionTile`'s own state) — it is not persisted, so navigating to a different day or reopening the screen recomputes "latest" fresh, which is the desired behavior.
- No requirement to auto-collapse other sections when one is expanded (`ExpansionTile` doesn't do this by default, and the spec doesn't call for it — only the *initial* state needs the "one open, rest closed" rule).

## 2. Carbs label fix

`app_ru.arb`: `dayLabelCarbs` changes from `"Углеводы"` to `"Углев-ы"`. No code change — `_ProgressRow` already renders whatever `loc.dayLabelCarbs` returns in a fixed 70px `SizedBox`. English (`"Carbs"`) is unaffected.

## 3. Entry tile: bigger kcal + macro line

Current `ListTile.trailing` is a single `Text(loc.dayEntryKcal(...))`. Replace with:

```dart
trailing: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(loc.dayEntryKcal(entry.kcalSnapshot.round()),
        style: Theme.of(context).textTheme.titleMedium),
    Text(
      '${entry.proteinSnapshot.round()}/${entry.fatSnapshot.round()}/${entry.carbsSnapshot.round()} ${loc.dayEntryMacroSuffix}',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  ],
),
```

New arb key `dayEntryMacroSuffix`: ru `"Б/Ж/У"`, en `"P/F/C"`. Order is always protein/fat/carbs, matching the suffix letter order in both locales.

## 4. Goals field pickers

New reusable widget: `lib/ui/widgets/option_picker_tile.dart`

```dart
class OptionPickerTile<T> extends StatelessWidget {
  final String fieldLabel;
  final String currentValueLabel;
  final List<T> options;
  final String Function(T) optionLabel;
  final String Function(T) optionDescription;
  final ValueChanged<T> onChanged;
  final Key? fieldKey;
}
```

- Renders a `ListTile(title: Text('$fieldLabel: $currentValueLabel'))` with a chevron affordance, wrapped in `InkWell`/`onTap`.
- Tap opens `showModalBottomSheet`: a `ListView` of `ListTile(title: Text(optionLabel(o)), subtitle: Text(optionDescription(o)))` per option. Tapping an option calls `onChanged(o)` and `Navigator.pop`.
- `GoalsScreen` replaces its three `DropdownButton`s (Sex, ActivityLevel, GoalType) with `OptionPickerTile` instances, keeping the existing `Key`s (`calcSexField`, etc.) on the tile itself so existing test lookups still resolve.

Fields always have a non-null default (`Sex.male`, `ActivityLevel.sedentary`, `GoalType.maintain`), so there is no "not selected" state to design for — the tile always shows a real current value.

### New arb keys

Field labels:
- `goalsSexFieldLabel`: ru "Пол" / en "Sex"
- `goalsActivityFieldLabel`: ru "Образ жизни" / en "Activity level"
- `goalsGoalTypeFieldLabel`: ru "Цель" / en "Goal"

Option descriptions (shown as modal subtitle). Sex descriptions explain the effect on the BMR formula coefficient, not what the sex categories mean; activity/goal descriptions explain when to pick each option, matching the multipliers in `bmr_calculator.dart`:

| Key | Ru | En |
|---|---|---|
| `goalsSexMaleDescription` | Используется в формуле расчёта базового обмена веществ (коэффициент +5) | Used in the basal metabolic rate formula (offset +5) |
| `goalsSexFemaleDescription` | Используется в формуле расчёта базового обмена веществ (коэффициент −161) | Used in the basal metabolic rate formula (offset −161) |
| `goalsActivitySedentaryDescription` | Мало или нет физической активности, сидячая работа | Little or no exercise, desk job |
| `goalsActivityLightDescription` | Лёгкие тренировки 1–3 раза в неделю | Light exercise 1–3 days a week |
| `goalsActivityModerateDescription` | Умеренные тренировки 3–5 раз в неделю | Moderate exercise 3–5 days a week |
| `goalsActivityHighDescription` | Интенсивные тренировки 6–7 раз в неделю | Hard exercise 6–7 days a week |
| `goalsGoalTypeLoseDescription` | Дефицит калорий для снижения веса | Calorie deficit to lose weight |
| `goalsGoalTypeMaintainDescription` | Расход калорий на уровне нормы, вес остаётся прежним | Calories at maintenance level, weight stays the same |
| `goalsGoalTypeGainDescription` | Профицит калорий для набора массы | Calorie surplus to gain weight |

## Testing impact

Existing widget tests (`test/ui/day_screen_test.dart`, `test/ui/goals_screen_test.dart`) don't assert on dropdown/expansion internals directly — they rely on default values and text lookups by key/content, which remain valid:
- Day screen tests with a single meal: that meal is both latest and only one, so it's expanded by default — entry text stays visible without needing to tap the header.
- The gap-window test only checks meal header text presence ("Meal 1"/"Meal 2"), not entry visibility, so section order/collapse state doesn't affect it.
- Goals screen tests never interact with Sex/Activity/Goal fields (they rely on defaults), so swapping `DropdownButton` for `OptionPickerTile` doesn't require test changes, provided the same `Key`s are preserved on the new tiles.

No new automated tests are required beyond manual verification of the new interactions (accordion expand/collapse, picker modal, macro line rendering) since existing coverage already exercises the surrounding flows.
