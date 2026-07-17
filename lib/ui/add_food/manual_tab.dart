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
              final kcal = double.tryParse(kcalController.text);
              final protein = double.tryParse(proteinController.text);
              final fat = double.tryParse(fatController.text);
              final carbs = double.tryParse(carbsController.text);
              final nutrients = [kcal, protein, fat, carbs];
              if (nutrients.any((v) => v == null || !v.isFinite || v < 0)) {
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
