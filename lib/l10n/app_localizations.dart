import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @navDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get navDay;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsGapWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal grouping gap: {minutes} minutes'**
  String settingsGapWindowLabel(int minutes);

  /// No description provided for @settingsGapWindowSliderLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String settingsGapWindowSliderLabel(int minutes);

  /// No description provided for @settingsExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export data (JSON)'**
  String get settingsExportButton;

  /// No description provided for @settingsImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import data (JSON)'**
  String get settingsImportButton;

  /// No description provided for @settingsImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current data?'**
  String get settingsImportConfirmTitle;

  /// No description provided for @settingsImportConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Importing will overwrite all current data. This cannot be undone.'**
  String get settingsImportConfirmBody;

  /// No description provided for @settingsCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancelButton;

  /// No description provided for @settingsReplaceButton.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get settingsReplaceButton;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported'**
  String get settingsImportSuccess;

  /// No description provided for @settingsImportFailure.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsImportFailure(String error);

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @goalsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Goals saved'**
  String get goalsSavedMessage;

  /// No description provided for @goalsSaveFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to save goals: {error}'**
  String goalsSaveFailure(String error);

  /// No description provided for @goalsModeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get goalsModeManual;

  /// No description provided for @goalsModeCalculated.
  ///
  /// In en, this message translates to:
  /// **'Calculated'**
  String get goalsModeCalculated;

  /// No description provided for @goalsDailyKcalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily kcal'**
  String get goalsDailyKcalLabel;

  /// No description provided for @goalsProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get goalsProteinLabel;

  /// No description provided for @goalsFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get goalsFatLabel;

  /// No description provided for @goalsCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get goalsCarbsLabel;

  /// No description provided for @goalsAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get goalsAgeLabel;

  /// No description provided for @goalsWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get goalsWeightLabel;

  /// No description provided for @goalsHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get goalsHeightLabel;

  /// No description provided for @goalsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get goalsSaveButton;

  /// No description provided for @goalsSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get goalsSexMale;

  /// No description provided for @goalsSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get goalsSexFemale;

  /// No description provided for @goalsActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get goalsActivitySedentary;

  /// No description provided for @goalsActivityLight.
  ///
  /// In en, this message translates to:
  /// **'Light activity'**
  String get goalsActivityLight;

  /// No description provided for @goalsActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate activity'**
  String get goalsActivityModerate;

  /// No description provided for @goalsActivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High activity'**
  String get goalsActivityHigh;

  /// No description provided for @goalsGoalTypeLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get goalsGoalTypeLose;

  /// No description provided for @goalsGoalTypeMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get goalsGoalTypeMaintain;

  /// No description provided for @goalsGoalTypeGain.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get goalsGoalTypeGain;

  /// No description provided for @goalsSexFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get goalsSexFieldLabel;

  /// No description provided for @goalsActivityFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get goalsActivityFieldLabel;

  /// No description provided for @goalsGoalTypeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalsGoalTypeFieldLabel;

  /// No description provided for @goalsSexMaleDescription.
  ///
  /// In en, this message translates to:
  /// **'Used in the basal metabolic rate formula (offset +5)'**
  String get goalsSexMaleDescription;

  /// No description provided for @goalsSexFemaleDescription.
  ///
  /// In en, this message translates to:
  /// **'Used in the basal metabolic rate formula (offset −161)'**
  String get goalsSexFemaleDescription;

  /// No description provided for @goalsActivitySedentaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Little or no exercise, desk job'**
  String get goalsActivitySedentaryDescription;

  /// No description provided for @goalsActivityLightDescription.
  ///
  /// In en, this message translates to:
  /// **'Light exercise 1–3 days a week'**
  String get goalsActivityLightDescription;

  /// No description provided for @goalsActivityModerateDescription.
  ///
  /// In en, this message translates to:
  /// **'Moderate exercise 3–5 days a week'**
  String get goalsActivityModerateDescription;

  /// No description provided for @goalsActivityHighDescription.
  ///
  /// In en, this message translates to:
  /// **'Hard exercise 6–7 days a week'**
  String get goalsActivityHighDescription;

  /// No description provided for @goalsGoalTypeLoseDescription.
  ///
  /// In en, this message translates to:
  /// **'Calorie deficit to lose weight'**
  String get goalsGoalTypeLoseDescription;

  /// No description provided for @goalsGoalTypeMaintainDescription.
  ///
  /// In en, this message translates to:
  /// **'Calories at maintenance level, weight stays the same'**
  String get goalsGoalTypeMaintainDescription;

  /// No description provided for @goalsGoalTypeGainDescription.
  ///
  /// In en, this message translates to:
  /// **'Calorie surplus to gain weight'**
  String get goalsGoalTypeGainDescription;

  /// No description provided for @addFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get addFoodTitle;

  /// No description provided for @addFoodTabRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get addFoodTabRecent;

  /// No description provided for @addFoodTabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get addFoodTabSearch;

  /// No description provided for @addFoodTabBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get addFoodTabBarcode;

  /// No description provided for @addFoodTabManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get addFoodTabManual;

  /// No description provided for @addFoodOnlyFavorites.
  ///
  /// In en, this message translates to:
  /// **'Only favorites'**
  String get addFoodOnlyFavorites;

  /// No description provided for @addFoodNoFavoriteRecentFoods.
  ///
  /// In en, this message translates to:
  /// **'No favorite recent foods yet'**
  String get addFoodNoFavoriteRecentFoods;

  /// No description provided for @addFoodNoRecentFoods.
  ///
  /// In en, this message translates to:
  /// **'No recent foods yet'**
  String get addFoodNoRecentFoods;

  /// No description provided for @addFoodKcalPer100g.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal / 100g'**
  String addFoodKcalPer100g(int kcal);

  /// No description provided for @addFoodFavoriteUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorite'**
  String get addFoodFavoriteUpdateFailed;

  /// No description provided for @addFoodSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get addFoodSearchLabel;

  /// No description provided for @addFoodInYourFoodsSuffix.
  ///
  /// In en, this message translates to:
  /// **' (in your foods)'**
  String get addFoodInYourFoodsSuffix;

  /// No description provided for @addFoodBarcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found — enter it manually'**
  String get addFoodBarcodeNotFound;

  /// No description provided for @addFoodAddManuallyButton.
  ///
  /// In en, this message translates to:
  /// **'Add food manually'**
  String get addFoodAddManuallyButton;

  /// No description provided for @addFoodSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Food saved'**
  String get addFoodSavedMessage;

  /// No description provided for @addFoodDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Food details'**
  String get addFoodDialogTitle;

  /// No description provided for @addFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addFoodNameLabel;

  /// No description provided for @addFoodKcalLabel.
  ///
  /// In en, this message translates to:
  /// **'Kcal / 100g'**
  String get addFoodKcalLabel;

  /// No description provided for @addFoodProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein / 100g'**
  String get addFoodProteinLabel;

  /// No description provided for @addFoodFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat / 100g'**
  String get addFoodFatLabel;

  /// No description provided for @addFoodCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs / 100g'**
  String get addFoodCarbsLabel;

  /// No description provided for @addFoodGramsEatenLabel.
  ///
  /// In en, this message translates to:
  /// **'Grams eaten'**
  String get addFoodGramsEatenLabel;

  /// No description provided for @addFoodFavoriteLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get addFoodFavoriteLabel;

  /// No description provided for @addFoodNutrientError.
  ///
  /// In en, this message translates to:
  /// **'Nutrient values must be non-negative numbers'**
  String get addFoodNutrientError;

  /// No description provided for @addFoodNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter a product name'**
  String get addFoodNameRequiredError;

  /// No description provided for @addFoodCaloriesRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Calories must be greater than zero'**
  String get addFoodCaloriesRequiredError;

  /// No description provided for @addFoodGramsError.
  ///
  /// In en, this message translates to:
  /// **'Grams eaten must be a positive number'**
  String get addFoodGramsError;

  /// No description provided for @addFoodCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addFoodCancelButton;

  /// No description provided for @addFoodSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addFoodSaveButton;

  /// No description provided for @addFoodAddProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addFoodAddProductButton;

  /// No description provided for @addFoodAddProductDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get addFoodAddProductDialogTitle;

  /// No description provided for @addFoodNoProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get addFoodNoProductsYet;

  /// No description provided for @addFoodNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get addFoodNoSearchResults;

  /// No description provided for @dayNoMealsLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get dayNoMealsLoggedYet;

  /// No description provided for @dayLabelKcal.
  ///
  /// In en, this message translates to:
  /// **'Kcal'**
  String get dayLabelKcal;

  /// No description provided for @dayLabelProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get dayLabelProtein;

  /// No description provided for @dayLabelFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get dayLabelFat;

  /// No description provided for @dayLabelCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get dayLabelCarbs;

  /// No description provided for @dayMealSection.
  ///
  /// In en, this message translates to:
  /// **'Meal {number}'**
  String dayMealSection(int number);

  /// No description provided for @dayEntryGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String dayEntryGrams(int grams);

  /// No description provided for @dayEntryKcal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String dayEntryKcal(int kcal);

  /// No description provided for @dayEntryMacroSuffix.
  ///
  /// In en, this message translates to:
  /// **'P/F/C'**
  String get dayEntryMacroSuffix;

  /// No description provided for @dayGramsEatenLabel.
  ///
  /// In en, this message translates to:
  /// **'Grams eaten'**
  String get dayGramsEatenLabel;

  /// No description provided for @dayCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dayCancelButton;

  /// No description provided for @daySaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get daySaveButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
