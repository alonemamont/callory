import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callory/domain/bmr_calculator.dart';
import 'package:callory/providers/providers.dart';

enum _Mode { manual, calculated }

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  _Mode _mode = _Mode.manual;

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
      await goalsRepo.setCalculatedGoals(BmrInput(
        sex: _sex,
        age: int.tryParse(_ageController.text) ?? 0,
        weightKg: double.tryParse(_weightController.text) ?? 0,
        heightCm: double.tryParse(_heightController.text) ?? 0,
        activityLevel: _activityLevel,
        goalType: _goalType,
      ));
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
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
            TextField(
              key: const Key('manualKcalField'),
              controller: _kcalController,
              decoration: const InputDecoration(labelText: 'Daily kcal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _proteinController,
              decoration: const InputDecoration(labelText: 'Protein (g)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _fatController,
              decoration: const InputDecoration(labelText: 'Fat (g)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _carbsController,
              decoration: const InputDecoration(labelText: 'Carbs (g)'),
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            DropdownButton<Sex>(
              value: _sex,
              items: Sex.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (value) => setState(() => _sex = value!),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
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
