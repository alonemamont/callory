# Goals Save-Button Dirty-State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Disable the Save button on the Goals screen whenever the current form state matches what's already persisted, so there's nothing to save.

**Architecture:** `GoalsScreen` snapshots the loaded (or just-saved) field values as a "baseline" after load and after every successful save. A `_hasChanges` getter compares the active mode's live field values against that baseline; the Save button's `onPressed` is `_hasChanges ? _save : null`. `TextEditingController` listeners force a rebuild on every keystroke so the comparison re-evaluates live.

**Tech Stack:** Flutter, `flutter_riverpod`, `drift` (existing `AppDatabase.forTesting(NativeDatabase.memory())` pattern for widget tests).

## Global Constraints

- Scope is `lib/ui/goals/goals_screen.dart` and its test file only — no repository or schema changes (per spec).
- No visual "unsaved changes" indicator beyond the button's disabled state; no navigate-away confirmation (per spec, explicitly out of scope).
- Text-field comparisons use the raw displayed string (not parsed numbers), so a value that parses equal but is formatted differently counts as changed (per spec).
- When no goals have ever been saved (`_baselineMode == null`), the Save button is always enabled (per spec: "always allow first save").

---

### Task 1: Baseline snapshot + dirty-state Save button

**Files:**
- Modify: `lib/ui/goals/goals_screen.dart`
- Test: `test/ui/goals_screen_test.dart`

**Interfaces:**
- Consumes: existing `GoalsScreen` state — `_mode`, `_kcalController`/`_proteinController`/`_fatController`/`_carbsController`, `_ageController`/`_weightController`/`_heightController`, `_sex`, `_activityLevel`, `_goalType`, `_loadExistingGoals()`, `_save()` (all defined in the current file, see below).
- Produces: `bool get _hasBaseline`, `bool get _hasChanges`, `void _captureBaseline()` — private to `_GoalsScreenState`, not consumed outside this file.

Current relevant code (for reference — this is what step 3 modifies):

```dart
// lib/ui/goals/goals_screen.dart, lines 19-64
class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  _Mode _mode = _Mode.manual;
  bool _loading = true;

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

  @override
  void initState() {
    super.initState();
    _loadExistingGoals();
  }

  Future<void> _loadExistingGoals() async {
    final goals = await ref.read(goalsRepositoryProvider).getGoals();
    if (!mounted) return;
    if (goals == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _mode = goals.mode == GoalsMode.calculated ? _Mode.calculated : _Mode.manual;
      _kcalController.text = _formatNumber(goals.dailyKcal);
      _proteinController.text = _formatNumber(goals.dailyProtein);
      _fatController.text = _formatNumber(goals.dailyFat);
      _carbsController.text = _formatNumber(goals.dailyCarbs);
      if (goals.age != null) _ageController.text = goals.age.toString();
      if (goals.weightKg != null) _weightController.text = _formatNumber(goals.weightKg!);
      if (goals.heightCm != null) _heightController.text = _formatNumber(goals.heightCm!);
      if (goals.sex != null) _sex = Sex.values.byName(goals.sex!);
      if (goals.activityLevel != null) {
        _activityLevel = ActivityLevel.values.byName(goals.activityLevel!);
      }
      if (goals.goalType != null) _goalType = GoalType.values.byName(goals.goalType!);
      _loading = false;
    });
  }
```

- [ ] **Step 1: Write the failing tests**

Add these four `testWidgets` blocks to `test/ui/goals_screen_test.dart`, inside the existing `main()` alongside the current tests (same imports already present — no new imports needed):

```dart
  testWidgets('manual mode: Save disables after saving, re-enables on edit, disables again on revert', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    ElevatedButton saveButton() =>
        tester.widget<ElevatedButton>(find.byKey(const Key('saveGoalsButton')));

    // No goals saved yet: button starts enabled even though nothing was typed.
    expect(saveButton().onPressed, isNotNull);

    await tester.enterText(find.byKey(const Key('manualKcalField')), '2200');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    // Right after saving, the form matches what was just saved: disabled.
    expect(saveButton().onPressed, isNull);

    // Editing a field re-enables it.
    await tester.enterText(find.byKey(const Key('manualKcalField')), '2300');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNotNull);

    // Reverting the edit back to the saved value disables it again.
    await tester.enterText(find.byKey(const Key('manualKcalField')), '2200');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNull);

    await db.close();
  });

  testWidgets('calculated mode: editing a field after save re-enables Save, reverting disables it', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculated'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('calcAgeField')), '30');
    await tester.enterText(find.byKey(const Key('calcWeightField')), '80');
    await tester.enterText(find.byKey(const Key('calcHeightField')), '180');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    ElevatedButton saveButton() =>
        tester.widget<ElevatedButton>(find.byKey(const Key('saveGoalsButton')));
    expect(saveButton().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('calcAgeField')), '31');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNotNull);

    await tester.enterText(find.byKey(const Key('calcAgeField')), '30');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNull);

    await db.close();
  });

  testWidgets('switching mode after a save re-enables Save even with unchanged fields', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculated'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('calcAgeField')), '30');
    await tester.enterText(find.byKey(const Key('calcWeightField')), '80');
    await tester.enterText(find.byKey(const Key('calcHeightField')), '180');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    ElevatedButton saveButton() =>
        tester.widget<ElevatedButton>(find.byKey(const Key('saveGoalsButton')));
    expect(saveButton().onPressed, isNull);

    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNotNull);

    await tester.tap(find.text('Calculated'));
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNull);

    await db.close();
  });

  testWidgets('reopening Goals after saving loads with Save disabled', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('manualKcalField')), '2000');
    await tester.tap(find.byKey(const Key('saveGoalsButton')));
    await tester.pumpAndSettle();

    // Simulate navigating away and back: the home shell replaces the tab
    // body widget rather than using an IndexedStack, so GoalsScreen state is
    // disposed and rebuilt from scratch (see the existing "reopening Goals"
    // test above for the same pattern).
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: wrapWithLocalizations(const GoalsScreen()),
    ));
    await tester.pumpAndSettle();

    final saveButton =
        tester.widget<ElevatedButton>(find.byKey(const Key('saveGoalsButton')));
    expect(saveButton.onPressed, isNull);

    await db.close();
  });
```

- [ ] **Step 2: Run the new tests to verify they fail**

Run: `E:/work/flutter/bin/flutter.bat test test/ui/goals_screen_test.dart`

Expected: the first new test (`manual mode: Save disables after saving...`) FAILS at `expect(saveButton().onPressed, isNull)` right after the save — today `onPressed` is always the `_save` method, never `null`. The other three new tests fail for the same reason (button never disables).

- [ ] **Step 3: Implement the baseline snapshot and dirty-state check**

In `lib/ui/goals/goals_screen.dart`:

1. Add baseline fields to `_GoalsScreenState`, right after the existing `GoalType _goalType = GoalType.maintain;` field (line 33):

```dart
  _Mode? _baselineMode;
  String? _baselineKcalText;
  String? _baselineProteinText;
  String? _baselineFatText;
  String? _baselineCarbsText;
  String? _baselineAgeText;
  String? _baselineWeightText;
  String? _baselineHeightText;
  Sex? _baselineSex;
  ActivityLevel? _baselineActivityLevel;
  GoalType? _baselineGoalType;
```

2. Replace `initState` (lines 35-38) to wire up rebuild-on-keystroke listeners, and add a matching `dispose`:

```dart
  @override
  void initState() {
    super.initState();
    for (final c in _textControllers) {
      c.addListener(_onFieldChanged);
    }
    _loadExistingGoals();
  }

  @override
  void dispose() {
    for (final c in _textControllers) {
      c.removeListener(_onFieldChanged);
    }
    super.dispose();
  }

  List<TextEditingController> get _textControllers => [
        _kcalController,
        _proteinController,
        _fatController,
        _carbsController,
        _ageController,
        _weightController,
        _heightController,
      ];

  void _onFieldChanged() => setState(() {});
```

3. At the end of `_loadExistingGoals` (after the closing `});` of its `setState` call, still inside the method), add a call to capture the baseline:

```dart
  Future<void> _loadExistingGoals() async {
    final goals = await ref.read(goalsRepositoryProvider).getGoals();
    if (!mounted) return;
    if (goals == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _mode = goals.mode == GoalsMode.calculated ? _Mode.calculated : _Mode.manual;
      _kcalController.text = _formatNumber(goals.dailyKcal);
      _proteinController.text = _formatNumber(goals.dailyProtein);
      _fatController.text = _formatNumber(goals.dailyFat);
      _carbsController.text = _formatNumber(goals.dailyCarbs);
      if (goals.age != null) _ageController.text = goals.age.toString();
      if (goals.weightKg != null) _weightController.text = _formatNumber(goals.weightKg!);
      if (goals.heightCm != null) _heightController.text = _formatNumber(goals.heightCm!);
      if (goals.sex != null) _sex = Sex.values.byName(goals.sex!);
      if (goals.activityLevel != null) {
        _activityLevel = ActivityLevel.values.byName(goals.activityLevel!);
      }
      if (goals.goalType != null) _goalType = GoalType.values.byName(goals.goalType!);
      _loading = false;
    });
    _captureBaseline();
  }

  void _captureBaseline() {
    _baselineMode = _mode;
    _baselineKcalText = _kcalController.text;
    _baselineProteinText = _proteinController.text;
    _baselineFatText = _fatController.text;
    _baselineCarbsText = _carbsController.text;
    _baselineAgeText = _ageController.text;
    _baselineWeightText = _weightController.text;
    _baselineHeightText = _heightController.text;
    _baselineSex = _sex;
    _baselineActivityLevel = _activityLevel;
    _baselineGoalType = _goalType;
  }

  bool get _hasBaseline => _baselineMode != null;

  bool get _hasChanges {
    if (!_hasBaseline) return true;
    if (_mode != _baselineMode) return true;
    if (_mode == _Mode.manual) {
      return _kcalController.text != _baselineKcalText ||
          _proteinController.text != _baselineProteinText ||
          _fatController.text != _baselineFatText ||
          _carbsController.text != _baselineCarbsText;
    }
    return _sex != _baselineSex ||
        _ageController.text != _baselineAgeText ||
        _weightController.text != _baselineWeightText ||
        _heightController.text != _baselineHeightText ||
        _activityLevel != _baselineActivityLevel ||
        _goalType != _baselineGoalType;
  }
```

(`_captureBaseline` unconditionally snapshots both the manual and calculated field sets on every call. This is simpler than tracking "no baseline yet for the other mode" separately, and produces the same externally observable behavior: the `_mode != _baselineMode` check in `_hasChanges` already forces the button enabled immediately after any mode switch, regardless of what the other mode's baseline holds.)

4. Update `_save()` to capture the baseline after each successful save — replace lines 107-149 with:

```dart
  Future<void> _save() async {
    final loc = AppLocalizations.of(context)!;
    final goalsRepo = ref.read(goalsRepositoryProvider);
    try {
      if (_mode == _Mode.manual) {
        await goalsRepo.setManualGoals(
          dailyKcal: double.tryParse(_kcalController.text) ?? 0,
          dailyProtein: double.tryParse(_proteinController.text) ?? 0,
          dailyFat: double.tryParse(_fatController.text) ?? 0,
          dailyCarbs: double.tryParse(_carbsController.text) ?? 0,
        );
        if (!mounted) return;
        setState(_captureBaseline);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.goalsSavedMessage)),
        );
      } else {
        final result = await goalsRepo.setCalculatedGoals(BmrInput(
          sex: _sex,
          age: int.tryParse(_ageController.text) ?? 0,
          weightKg: double.tryParse(_weightController.text) ?? 0,
          heightCm: double.tryParse(_heightController.text) ?? 0,
          activityLevel: _activityLevel,
          goalType: _goalType,
        ));
        if (!mounted) return;
        // Populate the manual fields with the computed numbers so switching to
        // Manual immediately shows an editable starting point (per spec: an
        // override afterward switches the stored record to manual mode).
        setState(() {
          _kcalController.text = _formatNumber(result.kcal);
          _proteinController.text = _formatNumber(result.proteinG);
          _fatController.text = _formatNumber(result.fatG);
          _carbsController.text = _formatNumber(result.carbsG);
          _captureBaseline();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.goalsSaveFailure(e.toString()))),
        );
      }
    }
  }
```

(On the `catch` path nothing calls `_captureBaseline`, so the baseline is left unchanged and the button stays enabled for a retry — matches the spec.)

5. Update the Save button's `onPressed` (around line 242):

```dart
          ElevatedButton(
            key: const Key('saveGoalsButton'),
            onPressed: _hasChanges ? _save : null,
            child: Text(loc.goalsSaveButton),
          ),
```

- [ ] **Step 4: Run the new tests to verify they pass**

Run: `E:/work/flutter/bin/flutter.bat test test/ui/goals_screen_test.dart`

Expected: all 10 tests in the file PASS (6 pre-existing + 4 new).

- [ ] **Step 5: Run the full test suite to check for regressions**

Run: `E:/work/flutter/bin/flutter.bat test`

Expected: all tests PASS, no regressions elsewhere (nothing outside `goals_screen.dart` reads `_hasChanges`/`_baselineMode`/etc., and the Save button's `Key` and label are unchanged).

- [ ] **Step 6: Commit**

```bash
git add lib/ui/goals/goals_screen.dart test/ui/goals_screen_test.dart
git commit -m "feat: disable Goals Save button when there are no unsaved changes"
```
