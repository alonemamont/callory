import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/bmr_calculator.dart';
import 'package:callory/l10n/app_localizations.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/widgets/number_field.dart';
import 'package:callory/ui/widgets/option_picker_tile.dart';

enum _Mode { manual, calculated }

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

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

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }

  String _sexLabel(AppLocalizations loc, Sex sex) => switch (sex) {
        Sex.male => loc.goalsSexMale,
        Sex.female => loc.goalsSexFemale,
      };

  String _activityLabel(AppLocalizations loc, ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => loc.goalsActivitySedentary,
        ActivityLevel.light => loc.goalsActivityLight,
        ActivityLevel.moderate => loc.goalsActivityModerate,
        ActivityLevel.high => loc.goalsActivityHigh,
      };

  String _goalTypeLabel(AppLocalizations loc, GoalType type) => switch (type) {
        GoalType.lose => loc.goalsGoalTypeLose,
        GoalType.maintain => loc.goalsGoalTypeMaintain,
        GoalType.gain => loc.goalsGoalTypeGain,
      };

  String _sexDescription(AppLocalizations loc, Sex sex) => switch (sex) {
        Sex.male => loc.goalsSexMaleDescription,
        Sex.female => loc.goalsSexFemaleDescription,
      };

  String _activityDescription(AppLocalizations loc, ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => loc.goalsActivitySedentaryDescription,
        ActivityLevel.light => loc.goalsActivityLightDescription,
        ActivityLevel.moderate => loc.goalsActivityModerateDescription,
        ActivityLevel.high => loc.goalsActivityHighDescription,
      };

  String _goalTypeDescription(AppLocalizations loc, GoalType type) => switch (type) {
        GoalType.lose => loc.goalsGoalTypeLoseDescription,
        GoalType.maintain => loc.goalsGoalTypeMaintainDescription,
        GoalType.gain => loc.goalsGoalTypeGainDescription,
      };

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.goalsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(loc.goalsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_Mode>(
            segments: [
              ButtonSegment(value: _Mode.manual, label: Text(loc.goalsModeManual)),
              ButtonSegment(value: _Mode.calculated, label: Text(loc.goalsModeCalculated)),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => setState(() => _mode = selection.first),
          ),
          const SizedBox(height: 16),
          if (_mode == _Mode.manual) ...[
            NumberField(
              fieldKey: const Key('manualKcalField'),
              controller: _kcalController,
              labelText: loc.goalsDailyKcalLabel,
            ),
            NumberField(
              fieldKey: const Key('manualProteinField'),
              controller: _proteinController,
              labelText: loc.goalsProteinLabel,
            ),
            NumberField(
              fieldKey: const Key('manualFatField'),
              controller: _fatController,
              labelText: loc.goalsFatLabel,
            ),
            NumberField(
              fieldKey: const Key('manualCarbsField'),
              controller: _carbsController,
              labelText: loc.goalsCarbsLabel,
            ),
          ] else ...[
            OptionPickerTile<Sex>(
              fieldKey: const Key('calcSexField'),
              fieldLabel: loc.goalsSexFieldLabel,
              currentValueLabel: _sexLabel(loc, _sex),
              options: Sex.values,
              optionLabel: (s) => _sexLabel(loc, s),
              optionDescription: (s) => _sexDescription(loc, s),
              onChanged: (value) => setState(() => _sex = value),
            ),
            NumberField(
              fieldKey: const Key('calcAgeField'),
              controller: _ageController,
              labelText: loc.goalsAgeLabel,
            ),
            NumberField(
              fieldKey: const Key('calcWeightField'),
              controller: _weightController,
              labelText: loc.goalsWeightLabel,
            ),
            NumberField(
              fieldKey: const Key('calcHeightField'),
              controller: _heightController,
              labelText: loc.goalsHeightLabel,
            ),
            OptionPickerTile<ActivityLevel>(
              fieldKey: const Key('calcActivityField'),
              fieldLabel: loc.goalsActivityFieldLabel,
              currentValueLabel: _activityLabel(loc, _activityLevel),
              options: ActivityLevel.values,
              optionLabel: (a) => _activityLabel(loc, a),
              optionDescription: (a) => _activityDescription(loc, a),
              onChanged: (value) => setState(() => _activityLevel = value),
            ),
            OptionPickerTile<GoalType>(
              fieldKey: const Key('calcGoalTypeField'),
              fieldLabel: loc.goalsGoalTypeFieldLabel,
              currentValueLabel: _goalTypeLabel(loc, _goalType),
              options: GoalType.values,
              optionLabel: (g) => _goalTypeLabel(loc, g),
              optionDescription: (g) => _goalTypeDescription(loc, g),
              onChanged: (value) => setState(() => _goalType = value),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('saveGoalsButton'),
            onPressed: _save,
            child: Text(loc.goalsSaveButton),
          ),
        ],
      ),
    );
  }
}
