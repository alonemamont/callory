# Goals screen: disable Save button when there's nothing to save

Date: 2026-07-17

## Problem

On the Goals tab (`lib/ui/goals/goals_screen.dart`), the Save button is always
enabled, even when the form matches exactly what's already persisted. The
user should not be able to press Save when there are no unsaved changes.

## Scope

`lib/ui/goals/goals_screen.dart` only. No repository or schema changes.

## Design

### Baseline snapshot

On load (`_loadExistingGoals`), after populating the controllers/fields from
the persisted `Goal` (or confirming there is none), capture a baseline
snapshot of the loaded state:

- `_baselineMode: _Mode?` — `null` if no goals exist yet, else the loaded mode.
- Manual fields baseline: kcal/protein/fat/carbs (as the loaded `double`
  values, or `null` when there's no baseline).
- Calculated fields baseline: sex/age/weight/height/activityLevel/goalType.

Both field-set baselines are captured regardless of the loaded mode (mirrors
today's `_loadExistingGoals`, which already populates all controllers from
the persisted row when present). Only the baseline for the active `_mode` is
used in the comparison below.

### Dirty check

```
bool get _hasBaseline => _baselineMode != null;

bool get _hasChanges {
  if (!_hasBaseline) return true; // nothing saved yet -> always allow first save
  if (_mode != _baselineMode) return true; // switching mode is itself a change
  if (_mode == _Mode.manual) {
    return _kcalController.text != _baselineKcalText
        || _proteinController.text != _baselineProteinText
        || _fatController.text != _baselineFatText
        || _carbsController.text != _baselineCarbsText;
  } else {
    return _sex != _baselineSex
        || _ageController.text != _baselineAgeText
        || _weightController.text != _baselineWeightText
        || _heightController.text != _baselineHeightText
        || _activityLevel != _baselineActivityLevel
        || _goalType != _baselineGoalType;
  }
}
```

Text fields are compared as the raw string currently shown (same formatting
`_formatNumber` produces for the baseline), not as parsed numbers — avoids
false "unchanged" reads when a user types a value that parses equal but is
formatted differently (e.g. trailing zero).

Save button:

```dart
ElevatedButton(
  key: const Key('saveGoalsButton'),
  onPressed: _hasChanges ? _save : null,
  child: Text(loc.goalsSaveButton),
)
```

### Rebuilding on every keystroke

`NumberField`'s `TextEditingController`s currently have no listener wired
into `GoalsScreen`, so typing doesn't trigger a rebuild there today. Add a
listener to each of the 7 controllers in `initState` (`() =>
setState(() {})`), removed in `dispose`. Picker fields (`OptionPickerTile`)
already go through `setState` in their `onChanged` callbacks, so no change
needed there.

### Updating the baseline after save

After a successful `_save()`:

- Manual branch: baseline becomes the just-saved manual values, `_baselineMode = _Mode.manual`.
- Calculated branch: baseline becomes the current calc inputs (sex/age/weight/height/activity/goalType), `_baselineMode = _Mode.calculated`. (Note: the calculated branch already copies the computed macros into the manual controllers as a starting point per existing behavior — that does not by itself count as a manual-mode save, so `_baselineMode` stays `calculated` and the manual baseline is left unset; if the user then flips to Manual mode, `_hasBaseline` for manual is false and Save is enabled, consistent with "no manual baseline exists yet".)

On save failure (caught exception), baseline is left unchanged — button stays enabled so the user can retry.

## Out of scope

- No visual "unsaved changes" indicator beyond the button's disabled state.
- No confirmation dialog when navigating away with unsaved changes.
