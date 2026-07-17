# Day Screen Datepicker — Design

## Problem
Day screen (`lib/ui/day/day_screen.dart`) navigates only one day at a time via prev/next chevrons in the AppBar. Jumping to a day far from today (e.g. two months back) requires many taps.

## Solution
Make the AppBar title (the formatted date) tappable. Tapping opens the platform `showDatePicker`, letting the user jump directly to any day.

### Trigger
Wrap the title `Text` in an `InkWell` (or `GestureDetector`) so the existing date text becomes the tap target — no new icon/button added.

### Behavior
- `onTap` calls:
  ```dart
  final picked = await showDatePicker(
    context: context,
    initialDate: selectedDay,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  ```
- No min/max restriction tied to "today" — the app already allows unlimited prev/next chevron navigation into past or future, so the picker should not be more restrictive.
- Locale (month names, first day of week, RTL, etc.) is inherited automatically from the app's existing `MaterialApp` locale/delegates setup — no extra wiring needed.
- If a date is picked (non-null), set `ref.read(selectedDayProvider.notifier).state = picked` — the same state update the chevrons already perform.
- If the dialog is dismissed (null), do nothing.

### Why this is sufficient
`selectedDayProvider` is the single source of truth the rest of `DayScreen.build` (meals, entries, goals `FutureBuilder`) already depends on. Changing it via the datepicker requires no other code changes — the screen re-fetches and rebuilds exactly as it does for chevron navigation.

## Out of scope
- No changes to chevron behavior.
- No date-range restrictions.
- No changes to how meals/entries are fetched or displayed.

## Testing
- Widget test: tap the AppBar title, confirm a date-picker dialog appears.
- Widget test: pick a date in the dialog, confirm the AppBar title updates to the picked date and confirm chevron navigation still works afterward (state wasn't left in a broken form).
