// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDay => 'Day';

  @override
  String get navAdd => 'Add';

  @override
  String get navGoals => 'Goals';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String settingsGapWindowLabel(int minutes) {
    return 'Meal grouping gap: $minutes minutes';
  }

  @override
  String settingsGapWindowSliderLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsExportButton => 'Export data (JSON)';

  @override
  String get settingsImportButton => 'Import data (JSON)';

  @override
  String get settingsImportConfirmTitle => 'Replace current data?';

  @override
  String get settingsImportConfirmBody =>
      'Importing will overwrite all current data. This cannot be undone.';

  @override
  String get settingsCancelButton => 'Cancel';

  @override
  String get settingsReplaceButton => 'Replace';

  @override
  String get settingsImportSuccess => 'Data imported';

  @override
  String settingsImportFailure(String error) {
    return 'Import failed: $error';
  }

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsSavedMessage => 'Goals saved';

  @override
  String goalsSaveFailure(String error) {
    return 'Failed to save goals: $error';
  }

  @override
  String get goalsModeManual => 'Manual';

  @override
  String get goalsModeCalculated => 'Calculated';

  @override
  String get goalsDailyKcalLabel => 'Daily kcal';

  @override
  String get goalsProteinLabel => 'Protein (g)';

  @override
  String get goalsFatLabel => 'Fat (g)';

  @override
  String get goalsCarbsLabel => 'Carbs (g)';

  @override
  String get goalsAgeLabel => 'Age';

  @override
  String get goalsWeightLabel => 'Weight (kg)';

  @override
  String get goalsHeightLabel => 'Height (cm)';

  @override
  String get goalsSaveButton => 'Save';

  @override
  String get goalsSexMale => 'Male';

  @override
  String get goalsSexFemale => 'Female';

  @override
  String get goalsActivitySedentary => 'Sedentary';

  @override
  String get goalsActivityLight => 'Light activity';

  @override
  String get goalsActivityModerate => 'Moderate activity';

  @override
  String get goalsActivityHigh => 'High activity';

  @override
  String get goalsGoalTypeLose => 'Lose weight';

  @override
  String get goalsGoalTypeMaintain => 'Maintain';

  @override
  String get goalsGoalTypeGain => 'Gain weight';

  @override
  String get goalsSexFieldLabel => 'Sex';

  @override
  String get goalsActivityFieldLabel => 'Activity level';

  @override
  String get goalsGoalTypeFieldLabel => 'Goal';

  @override
  String get goalsSexMaleDescription =>
      'Used in the basal metabolic rate formula (offset +5)';

  @override
  String get goalsSexFemaleDescription =>
      'Used in the basal metabolic rate formula (offset −161)';

  @override
  String get goalsActivitySedentaryDescription =>
      'Little or no exercise, desk job';

  @override
  String get goalsActivityLightDescription => 'Light exercise 1–3 days a week';

  @override
  String get goalsActivityModerateDescription =>
      'Moderate exercise 3–5 days a week';

  @override
  String get goalsActivityHighDescription => 'Hard exercise 6–7 days a week';

  @override
  String get goalsGoalTypeLoseDescription => 'Calorie deficit to lose weight';

  @override
  String get goalsGoalTypeMaintainDescription =>
      'Calories at maintenance level, weight stays the same';

  @override
  String get goalsGoalTypeGainDescription => 'Calorie surplus to gain weight';

  @override
  String get addFoodTitle => 'Add food';

  @override
  String get addFoodTabRecent => 'Recent';

  @override
  String get addFoodTabSearch => 'Search';

  @override
  String get addFoodTabBarcode => 'Barcode';

  @override
  String get addFoodTabManual => 'Manual';

  @override
  String get addFoodOnlyFavorites => 'Only favorites';

  @override
  String get addFoodNoFavoriteRecentFoods => 'No favorite recent foods yet';

  @override
  String get addFoodNoRecentFoods => 'No recent foods yet';

  @override
  String addFoodKcalPer100g(int kcal) {
    return '$kcal kcal / 100g';
  }

  @override
  String get addFoodFavoriteUpdateFailed => 'Could not update favorite';

  @override
  String get addFoodSearchLabel => 'Search foods';

  @override
  String get addFoodInYourFoodsSuffix => ' (in your foods)';

  @override
  String get addFoodBarcodeNotFound => 'Product not found — enter it manually';

  @override
  String get addFoodAddManuallyButton => 'Add food manually';

  @override
  String get addFoodSavedMessage => 'Food saved';

  @override
  String get addFoodDialogTitle => 'Food details';

  @override
  String get addFoodNameLabel => 'Name';

  @override
  String get addFoodKcalLabel => 'Kcal / 100g';

  @override
  String get addFoodProteinLabel => 'Protein / 100g';

  @override
  String get addFoodFatLabel => 'Fat / 100g';

  @override
  String get addFoodCarbsLabel => 'Carbs / 100g';

  @override
  String get addFoodGramsEatenLabel => 'Grams eaten';

  @override
  String get addFoodFavoriteLabel => 'Favorite';

  @override
  String get addFoodNutrientError =>
      'Nutrient values must be non-negative numbers';

  @override
  String get addFoodGramsError => 'Grams eaten must be a positive number';

  @override
  String get addFoodCancelButton => 'Cancel';

  @override
  String get addFoodSaveButton => 'Save';

  @override
  String get addFoodAddProductButton => 'Add product';

  @override
  String get addFoodAddProductDialogTitle => 'New product';

  @override
  String get addFoodNoProductsYet => 'No products yet';

  @override
  String get addFoodNoSearchResults => 'No matching products';

  @override
  String get dayNoMealsLoggedYet => 'No meals logged yet';

  @override
  String get dayLabelKcal => 'Kcal';

  @override
  String get dayLabelProtein => 'Protein';

  @override
  String get dayLabelFat => 'Fat';

  @override
  String get dayLabelCarbs => 'Carbs';

  @override
  String dayMealSection(int number) {
    return 'Meal $number';
  }

  @override
  String dayEntryGrams(int grams) {
    return '$grams g';
  }

  @override
  String dayEntryKcal(int kcal) {
    return '$kcal kcal';
  }

  @override
  String get dayEntryMacroSuffix => 'P/F/C';

  @override
  String get dayGramsEatenLabel => 'Grams eaten';

  @override
  String get dayCancelButton => 'Cancel';

  @override
  String get daySaveButton => 'Save';
}
