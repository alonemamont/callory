import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callory/db/database.dart';
import 'package:callory/providers/providers.dart';

final _dayRefreshProvider = StateProvider<int>((ref) => 0);

class DayScreen extends ConsumerWidget {
  const DayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final diaryRepo = ref.watch(diaryRepositoryProvider);
    final goalsRepo = ref.watch(goalsRepositoryProvider);
    ref.watch(_dayRefreshProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(selectedDay)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => ref.read(selectedDayProvider.notifier).state =
              selectedDay.subtract(const Duration(days: 1)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedDayProvider.notifier).state =
                selectedDay.add(const Duration(days: 1)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          diaryRepo.getMealsForDate(selectedDay),
          diaryRepo.getEntriesForDate(selectedDay),
          goalsRepo.getGoals(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final meals = snapshot.data![0] as List<Meal>;
          final entries = snapshot.data![1] as List<DiaryEntry>;
          final goals = snapshot.data![2] as Goal?;

          if (meals.isEmpty) {
            return const Center(child: Text('No meals logged yet'));
          }

          final totals = _sumTotals(entries);

          return Column(
            children: [
              if (goals != null) _GoalProgress(totals: totals, goals: goals),
              Expanded(
                child: ListView(
                  children: meals
                      .map((meal) => _MealSection(
                            meal: meal,
                            entries: entries.where((e) => e.mealId == meal.id).toList(),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ({double kcal, double protein, double fat, double carbs}) _sumTotals(
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

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _GoalProgress extends StatelessWidget {
  final ({double kcal, double protein, double fat, double carbs}) totals;
  final Goal goals;
  const _GoalProgress({required this.totals, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _ProgressRow(label: 'Kcal', actual: totals.kcal, goal: goals.dailyKcal),
          _ProgressRow(label: 'Protein', actual: totals.protein, goal: goals.dailyProtein),
          _ProgressRow(label: 'Fat', actual: totals.fat, goal: goals.dailyFat),
          _ProgressRow(label: 'Carbs', actual: totals.carbs, goal: goals.dailyCarbs),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double actual;
  final double goal;
  const _ProgressRow({required this.label, required this.actual, required this.goal});

  @override
  Widget build(BuildContext context) {
    final ratio = goal <= 0 ? 0.0 : (actual / goal).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label)),
          Expanded(child: LinearProgressIndicator(value: ratio)),
          const SizedBox(width: 8),
          Text('${actual.round()}/${goal.round()}'),
        ],
      ),
    );
  }
}

class _MealSection extends ConsumerWidget {
  final Meal meal;
  final List<DiaryEntry> entries;
  const _MealSection({required this.meal, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Прием ${meal.mealNumber}', style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final entry in entries)
          ListTile(
            title: Text(entry.foodNameSnapshot),
            subtitle: Text('${entry.grams.round()} g'),
            trailing: Text('${entry.kcalSnapshot.round()} kcal'),
            onTap: () => _showEditGramsDialog(context, ref, entry),
          ),
      ],
    );
  }

  Future<void> _showEditGramsDialog(
    BuildContext context,
    WidgetRef ref,
    DiaryEntry entry,
  ) async {
    final gramsController = TextEditingController(text: entry.grams.round().toString());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.foodNameSnapshot),
        content: TextField(
          key: const Key('editEntryGramsField'),
          controller: gramsController,
          decoration: const InputDecoration(labelText: 'Grams eaten'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed != true) return;

    final newGrams = double.tryParse(gramsController.text);
    if (newGrams == null || newGrams <= 0) return;

    await ref.read(diaryRepositoryProvider).updateEntryGrams(entry.id, newGrams);
    ref.read(_dayRefreshProvider.notifier).state++;
  }
}
