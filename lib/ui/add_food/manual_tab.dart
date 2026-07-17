import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/l10n/app_localizations.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/add_food/add_food_screen.dart' show logDiaryEntry;
import 'package:callory/ui/widgets/number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showAddProductDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final loc = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final kcalController = TextEditingController(text: '0');
  final proteinController = TextEditingController(text: '0');
  final fatController = TextEditingController(text: '0');
  final carbsController = TextEditingController(text: '0');
  var isFavorite = false;
  String? errorText;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(loc.addFoodAddProductDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: loc.addFoodNameLabel),
              ),
              NumberField(controller: kcalController, labelText: loc.addFoodKcalLabel),
              NumberField(controller: proteinController, labelText: loc.addFoodProteinLabel),
              NumberField(controller: fatController, labelText: loc.addFoodFatLabel),
              NumberField(controller: carbsController, labelText: loc.addFoodCarbsLabel),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isFavorite,
                title: Text(loc.addFoodFavoriteLabel),
                onChanged: (value) => setState(() => isFavorite = value ?? false),
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.addFoodCancelButton),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                setState(() => errorText = loc.addFoodNameRequiredError);
                return;
              }
              final kcal = double.tryParse(kcalController.text);
              if (kcal == null || !kcal.isFinite || kcal <= 0) {
                setState(() => errorText = loc.addFoodCaloriesRequiredError);
                return;
              }
              final protein = double.tryParse(proteinController.text);
              final fat = double.tryParse(fatController.text);
              final carbs = double.tryParse(carbsController.text);
              final otherNutrients = [protein, fat, carbs];
              if (otherNutrients.any((v) => v == null || !v.isFinite || v < 0)) {
                setState(() => errorText = loc.addFoodNutrientError);
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(loc.addFoodSaveButton),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return false;

  await ref.read(foodRepositoryProvider).insertFood(
        name: nameController.text,
        barcode: null,
        kcalPer100g: double.parse(kcalController.text),
        proteinPer100g: double.parse(proteinController.text),
        fatPer100g: double.parse(fatController.text),
        carbsPer100g: double.parse(carbsController.text),
        source: FoodSourceType.manual,
        isFavorite: isFavorite,
      );
  return true;
}

Future<bool> showLogExistingFoodDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FoodResult food,
}) async {
  final loc = AppLocalizations.of(context)!;
  final gramsController = TextEditingController(text: '100');
  String? errorText;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(food.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.addFoodKcalPer100g(food.kcalPer100g.round())),
            Text(
              '${food.proteinPer100g.round()}/${food.fatPer100g.round()}/'
              '${food.carbsPer100g.round()} ${loc.dayEntryMacroSuffix}',
            ),
            NumberField(
              controller: gramsController,
              labelText: loc.addFoodGramsEatenLabel,
              autofocus: true,
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.addFoodCancelButton),
          ),
          TextButton(
            onPressed: () {
              final grams = double.tryParse(gramsController.text);
              if (grams == null || !grams.isFinite || grams <= 0) {
                setState(() => errorText = loc.addFoodGramsError);
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(loc.addFoodSaveButton),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return false;

  await logDiaryEntry(
    ref,
    privateFoodId: food.existingPrivateFoodId!,
    name: food.name,
    grams: double.parse(gramsController.text),
    kcalPer100g: food.kcalPer100g,
    proteinPer100g: food.proteinPer100g,
    fatPer100g: food.fatPer100g,
    carbsPer100g: food.carbsPer100g,
  );
  return true;
}

class ManualTab extends ConsumerStatefulWidget {
  const ManualTab({super.key});

  @override
  ConsumerState<ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends ConsumerState<ManualTab> {
  late Future<List<FoodResult>> _allFoods;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _allFoods = ref.read(foodRepositoryProvider).getAllFoods();
  }

  void _refresh() {
    setState(() {
      _allFoods = ref.read(foodRepositoryProvider).getAllFoods();
    });
  }

  Future<void> _toggleFavorite(FoodResult food) async {
    await ref
        .read(foodRepositoryProvider)
        .setFavorite(food.existingPrivateFoodId!, !food.isFavorite);
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () async {
              final saved = await showAddProductDialog(context: context, ref: ref);
              if (saved && mounted) _refresh();
            },
            child: Text(loc.addFoodAddProductButton),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            decoration: InputDecoration(labelText: loc.addFoodSearchLabel),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<FoodResult>>(
            future: _allFoods,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snapshot.data ?? const <FoodResult>[];
              final filtered = _query.isEmpty
                  ? all
                  : all
                      .where((f) => f.name.toLowerCase().contains(_query.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    all.isEmpty ? loc.addFoodNoProductsYet : loc.addFoodNoSearchResults,
                  ),
                );
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final food = filtered[index];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text(loc.addFoodKcalPer100g(food.kcalPer100g.round())),
                    trailing: IconButton(
                      icon: Icon(food.isFavorite ? Icons.star : Icons.star_border),
                      onPressed: () => _toggleFavorite(food),
                    ),
                    onTap: () async {
                      final saved = await showLogExistingFoodDialog(
                        context: context,
                        ref: ref,
                        food: food,
                      );
                      if (saved && mounted) _refresh();
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
