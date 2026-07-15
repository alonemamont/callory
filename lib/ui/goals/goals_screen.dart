import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/bmr_calculator.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/widgets/number_field.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goals')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
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
            NumberField(
              fieldKey: const Key('manualKcalField'),
              controller: _kcalController,
              labelText: 'Daily kcal',
            ),
            NumberField(
              fieldKey: const Key('manualProteinField'),
              controller: _proteinController,
              labelText: 'Protein (g)',
            ),
            NumberField(
              fieldKey: const Key('manualFatField'),
              controller: _fatController,
              labelText: 'Fat (g)',
            ),
            NumberField(
              fieldKey: const Key('manualCarbsField'),
              controller: _carbsController,
              labelText: 'Carbs (g)',
            ),
          ] else ...[
            DropdownButton<Sex>(
              key: const Key('calcSexField'),
              value: _sex,
              items: Sex.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (value) => setState(() => _sex = value!),
            ),
            NumberField(
              fieldKey: const Key('calcAgeField'),
              controller: _ageController,
              labelText: 'Age',
            ),
            NumberField(
              fieldKey: const Key('calcWeightField'),
              controller: _weightController,
              labelText: 'Weight (kg)',
            ),
            NumberField(
              fieldKey: const Key('calcHeightField'),
              controller: _heightController,
              labelText: 'Height (cm)',
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
