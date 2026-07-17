# Day Screen Datepicker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the day screen's AppBar date title tappable, opening a datepicker so the user can jump directly to any day instead of only stepping one day at a time via the chevrons.

**Architecture:** Wrap the existing AppBar title `Text` in an `InkWell`. Tapping it calls the platform `showDatePicker`; a non-null result is written to the existing `selectedDayProvider` — the same state the chevrons already mutate, so the rest of `DayScreen` needs no changes.

**Tech Stack:** Flutter, Riverpod (`StateProvider`), Flutter's built-in `showDatePicker`.

## Global Constraints

- No date-range restriction: `firstDate: DateTime(2000)`, `lastDate: DateTime(2100)` (spec: "No limits").
- Trigger is the existing title text itself — no new icon/button (spec: "Tap date text").
- Locale/l10n comes from the app's existing `MaterialApp` delegates — no new wiring.

---

### Task 1: Tappable AppBar date opens a datepicker

**Files:**
- Modify: `lib/ui/day/day_screen.dart:20-35` (AppBar `title`), add a `_pickDate` method to the `DayScreen` class
- Test: `test/ui/day_screen_test.dart`

**Interfaces:**
- Consumes: `selectedDayProvider` (`StateProvider<DateTime>`, from `lib/providers/providers.dart`) — already imported in both files.
- Produces: nothing new consumed by later tasks (this is the only task).

- [ ] **Step 1: Write the failing test**

Add this test to `test/ui/day_screen_test.dart`, before the final closing `}` of `main()`:

```dart
  testWidgets(
    'tapping the app bar date opens a datepicker that jumps to the picked day',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
            selectedDayProvider.overrideWith((ref) => DateTime(2026, 7, 15)),
          ],
          child: wrapWithLocalizations(const DayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2026-07-15'), findsOneWidget);

      await tester.tap(find.text('2026-07-15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('2026-07-20'), findsOneWidget);

      await db.close();
    },
  );
```

This uses a fixed date (`DateTime(2026, 7, 15)`, well inside July, no month-boundary edge case) via `selectedDayProvider.overrideWith` so the test doesn't depend on what day it's run.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/ui/day_screen_test.dart`
Expected: FAIL — tapping the plain `Text('2026-07-15')` does nothing (no tap handler yet), so no datepicker dialog opens, and `find.text('20')` / `find.text('OK')` are not found (`findsOneWidget` / tap on nonexistent widget throws).

- [ ] **Step 3: Write minimal implementation**

In `lib/ui/day/day_screen.dart`, change the AppBar's `title` (currently `title: Text(_formatDate(selectedDay)),`) to:

```dart
        title: InkWell(
          onTap: () => _pickDate(context, ref, selectedDay),
          child: Text(_formatDate(selectedDay)),
        ),
```

Add this method to the `DayScreen` class (e.g. directly after `build`, before `_sumTotals`):

```dart
  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    ref.read(selectedDayProvider.notifier).state = picked;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/ui/day_screen_test.dart`
Expected: PASS (all tests in the file, including the new one).

- [ ] **Step 5: Commit**

```bash
git add lib/ui/day/day_screen.dart test/ui/day_screen_test.dart
git commit -m "feat: tap day screen date to open a datepicker"
```

---

## Self-Review Notes

- **Spec coverage:** trigger (tap title text) ✓, no range limits ✓, locale inherited automatically (no code needed) ✓, state update via `selectedDayProvider` ✓, widget tests for open + pick ✓. Chevron nav is untouched (no code change to those `IconButton`s), covered by pre-existing passing tests.
- **Placeholder scan:** none — every step has runnable code and exact commands.
- **Type consistency:** `_pickDate(BuildContext, WidgetRef, DateTime)` matches the call site `_pickDate(context, ref, selectedDay)`; `selectedDayProvider` type (`StateProvider<DateTime>`) matches `.overrideWith((ref) => DateTime(...))` and `.notifier.state = picked` usages elsewhere in the same file.
