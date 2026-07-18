# Nav, Search, Delete-Entry & Datepicker fixes — design

Date: 2026-07-18
Status: approved

## Scope

Five bounded, independent fixes/small features reported after manual testing, bundled as one PR (5 commits), same pattern as `2026-07-18-add-food-tab-fixes-design.md`:

1. Move the "Goals" bottom-nav tab into Settings as a "Set goals" list item.
2. Fix local-DB search not matching Cyrillic-cased product names.
3. Search fields (Add Food → Search tab, Add Food → Manual tab) remember their last-typed value across app restarts, and autofocus with all text selected when the screen opens.
4. Add a delete button (with confirmation) for a logged diary entry inside a meal, on the Day screen.
5. Day screen's datepicker closes and switches date immediately on tapping a day, without an OK button.

None of these interact with each other; independent to implement/verify.

## 1. Move Goals into Settings

`lib/main.dart`'s `_HomeShellState._screens` currently has 4 entries (`DayScreen`, `AddFoodScreen`, `GoalsScreen`, `SettingsScreen`) with 4 matching `NavigationDestination`s.

- Remove `GoalsScreen()` from `_screens` and its `NavigationDestination` (`Icons.flag`, `loc.navGoals`) from the `NavigationBar`. Bottom nav becomes 3 destinations: Day, Add, Settings.
- `lib/ui/settings/settings_screen.dart`: add a new `ListTile` in the `ListView`, placed right after the language `ListTile`'s `Divider` (before the export/import buttons):
  ```dart
  ListTile(
    title: Text(loc.settingsSetGoalsLabel),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GoalsScreen()),
    ),
  ),
  const Divider(height: 32),
  ```
- New ARB key `settingsSetGoalsLabel` in both `app_en.arb` ("Set goals") and `app_ru.arb` ("Задать цели").
- `GoalsScreen` already has its own `Scaffold`/`AppBar` (`goals_screen.dart:227,232`) — pushing it via `Navigator` gets a back button automatically, no changes needed inside `GoalsScreen`.
- `loc.navGoals` ARB key becomes unused by nav but is left in place (no other reason to remove a translated string; harmless dead key, consistent with not doing unrelated cleanup).

## 2. Local search: Cyrillic case-insensitivity

Root cause: `FoodRepository.searchByName` (`lib/data/food_repository.dart:97-108`) does the substring match with SQL `f.name.lower().like('%$escaped%', ...)`. SQLite's built-in `LOWER()` only case-folds ASCII `A-Z`; Cyrillic (and other non-ASCII) letters pass through unchanged. The query string is correctly lowercased by Dart's `query.toLowerCase()` before escaping, but the *column* side (`f.name.lower()`) is not — so `"Гречка"` stored in the DB never matches a typed `"гречка"`.

Fix: do the case-fold and substring match in Dart instead of SQL. Since this table holds a single user's private foods (not a large catalog), an in-memory filter is cheap:

```dart
@override
Future<List<FoodResult>> searchByName(String query) async {
  final needle = query.toLowerCase();
  final rows = await (db.select(db.privateFoods)
        ..orderBy([(f) => OrderingTerm.asc(f.name)]))
      .get();
  return rows
      .where((row) => row.name.toLowerCase().contains(needle))
      .map(_toResult)
      .toList();
}
```

- Drop the `\`, `%`, `_` escaping (`escaped` variable) — it existed only to safely build a SQL `LIKE` pattern; `String.contains` needs no escaping.
- No schema change. No change to `FoodLookupService` or the external source — this is a `FoodRepository`-only fix.

## 3. Search fields remember last query + autofocus/select-all

Applies to both `_SearchTab` (`lib/ui/add_food/add_food_screen.dart`) and `ManualTab`'s search field (`lib/ui/add_food/manual_tab.dart`).

### Persistence
- `SettingsService` (`lib/data/settings_service.dart`, SharedPreferences-backed) gets two new methods: `String get lastSearchQuery` / `Future<void> setLastSearchQuery(String)`, and `String get lastManualSearchQuery` / `Future<void> setLastManualSearchQuery(String)`. Default `''` when unset (matches the existing "empty query = no results yet" behavior).
- `_SearchTab.initState`: prefill `_controller.text` from `ref.read(settingsServiceProvider).lastSearchQuery`; if non-empty, immediately trigger `_search(...)` so results are visible on open, same as if the user had just typed it.
- `_onQueryChanged` (already debounced 1s): also call `settingsService.setLastSearchQuery(query)` alongside the existing debounce-triggered `_search` call — save on every change, not just on the debounce fire, so a value typed and abandoned (screen closed before the 1s debounce fires) is still remembered.
- `ManualTab`'s search field has no debounce today (`onChanged: (value) => setState(() => _query = value)`); add `settingsService.setLastManualSearchQuery(value)` to that same `onChanged`, and prefill `_query`/the field's controller from `lastManualSearchQuery` in `initState`.

### Autofocus + select-all
- Both fields get `autofocus: true`.
- Autofocus alone places the cursor at the end, it does not select existing text. Add a `FocusNode`, listen for focus gained, and on first focus set:
  ```dart
  _focusNode.addListener(() {
    if (_focusNode.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  });
  ```
  Attach `focusNode: _focusNode` to the `TextField`. Since the field also has `autofocus: true`, this listener fires once on screen open with the prefilled text already selected.

## 4. Delete a diary entry from a meal

`_MealSection` (`lib/ui/day/day_screen.dart:158-199`) renders each `DiaryEntry` as a `ListTile` with `trailing: Column(...)` showing kcal/macros. Wrap that `Column` and a new delete `IconButton` in a `Row`:

```dart
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(loc.dayEntryKcal(entry.kcalSnapshot.round()), style: Theme.of(context).textTheme.titleMedium),
        Text(
          '${entry.proteinSnapshot.round()}/${entry.fatSnapshot.round()}/${entry.carbsSnapshot.round()} ${loc.dayEntryMacroSuffix}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
    IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: () => _confirmDeleteEntry(context, ref, entry),
    ),
  ],
),
```

`_confirmDeleteEntry` (new top-level or `_MealSection`-private function, mirroring `ManualTab._confirmDelete`):

```dart
Future<void> _confirmDeleteEntry(BuildContext context, WidgetRef ref, DiaryEntry entry) async {
  final loc = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(loc.dayDeleteEntryConfirmMessage(entry.foodNameSnapshot)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.addFoodCancelButton)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.addFoodDeleteConfirmButton)),
      ],
    ),
  );
  if (confirmed != true) return;
  final gapWindow = ref.read(settingsServiceProvider).gapWindow;
  await ref.read(diaryRepositoryProvider).deleteEntry(entry.id, gapWindow);
  ref.read(_dayRefreshProvider.notifier).state++;
}
```

- Reuses existing `addFoodCancelButton` / `addFoodDeleteConfirmButton` labels (already added for the Manual-tab delete) — no need for new button-label keys.
- New ARB key `dayDeleteEntryConfirmMessage` with `{name}` placeholder — en: `"{name} will be removed from this meal. Confirm?"`, ru: `"{name} будет удален из приема пищи. Подтвердить?"`.
- `DiaryRepository.deleteEntry(int entryId, Duration gapWindow)` (`lib/data/diary_repository.dart:110`) already exists and already handles cleanup of an emptied manual meal — no repository change needed.
- Refresh via the existing `_dayRefreshProvider` bump, the same mechanism `_showEditGramsDialog` already uses elsewhere on this screen.

## 5. Datepicker closes on day tap

`DayScreen._pickDate` (`lib/ui/day/day_screen.dart:82-95`) currently calls the stock `showDatePicker`, which requires pressing OK to confirm. Replace with a custom dialog wrapping `CalendarDatePicker` directly:

```dart
Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime selectedDay) async {
  final picked = await showDialog<DateTime>(
    context: context,
    builder: (context) => Dialog(
      child: CalendarDatePicker(
        initialDate: selectedDay,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        onDateChanged: (date) => Navigator.pop(context, date),
      ),
    ),
  );
  if (picked == null) return;
  ref.read(selectedDayProvider.notifier).state = picked;
}
```

- `CalendarDatePicker.onDateChanged` fires the instant a day is tapped (before any confirm step) — popping the dialog there is what makes selection immediate, no OK button.
- Same `firstDate`/`lastDate` range as before (no restriction change).
- Dismissing the dialog without tapping a day (tap outside / back button) resolves `picked` as `null` — same no-op as today's cancel.
- Trade-off (confirmed acceptable): the stock `showDatePicker`'s keyboard-icon toggle for manual text entry of a date is not present in `CalendarDatePicker` used standalone — calendar-only interaction.
- Locale (month names, first day of week, RTL) is still inherited from the app's `MaterialApp` locale/delegates — `CalendarDatePicker` uses the same localization pipeline as `showDatePicker` internally.

## Out of scope

- No changes to `GoalsScreen` internals (item 1) beyond how it's navigated to.
- No changes to `FoodLookupService` or `OpenFoodFactsSource` (item 2) — private-source-only fix.
- No debounce added to `ManualTab`'s search-as-you-type (item 3) — only persistence is added; existing immediate-filter behavior is unchanged.
- No swipe-to-dismiss gesture for deleting diary entries (item 4) — button + dialog only, matching the Manual-tab delete pattern.
- No manual text-entry mode for the datepicker (item 5) — calendar-only, per confirmed trade-off.

## Testing

1. Widget test: `SettingsScreen` shows a "Set goals" tile that pushes `GoalsScreen`. Widget test: bottom `NavigationBar` has exactly 3 destinations (Day, Add, Settings), no Goals.
2. `food_repository_test.dart`: new test seeding a food named e.g. `"Гречка"` and asserting `searchByName('гречка')` returns it (case-insensitive Cyrillic match) — this test fails against current code and passes after the fix.
3. Widget tests for both tabs: (a) type a query, dispose/recreate the tab (simulating leaving and returning), assert the field is prefilled with the last value; (b) assert `autofocus` is `true` and, once focused, the controller's `TextSelection` spans the full prefilled text.
4. Widget test on `DayScreen`: seed a diary entry, tap its delete icon, confirm the dialog message contains the entry's name, cancel leaves it in place, confirm removes it and the meal section updates.
5. Widget test on `DayScreen`: tap the AppBar date, tap a day in the calendar, assert the dialog closes without any further tap and `selectedDayProvider`/AppBar title reflect the picked date.
