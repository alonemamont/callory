// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navDay => 'День';

  @override
  String get navAdd => 'Добавить';

  @override
  String get navGoals => 'Цели';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguageLabel => 'Язык';

  @override
  String settingsGapWindowLabel(int minutes) {
    return 'Интервал группировки приёмов пищи: $minutes мин';
  }

  @override
  String settingsGapWindowSliderLabel(int minutes) {
    return '$minutes мин';
  }

  @override
  String get settingsExportButton => 'Экспорт данных (JSON)';

  @override
  String get settingsImportButton => 'Импорт данных (JSON)';

  @override
  String get settingsImportConfirmTitle => 'Заменить текущие данные?';

  @override
  String get settingsImportConfirmBody =>
      'Импорт полностью перезапишет текущие данные. Это действие нельзя отменить.';

  @override
  String get settingsCancelButton => 'Отмена';

  @override
  String get settingsReplaceButton => 'Заменить';

  @override
  String get settingsImportSuccess => 'Данные импортированы';

  @override
  String settingsImportFailure(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get goalsTitle => 'Цели';

  @override
  String get goalsSavedMessage => 'Цели сохранены';

  @override
  String goalsSaveFailure(String error) {
    return 'Не удалось сохранить цели: $error';
  }

  @override
  String get goalsModeManual => 'Вручную';

  @override
  String get goalsModeCalculated => 'Расчёт';

  @override
  String get goalsDailyKcalLabel => 'Калории в день';

  @override
  String get goalsProteinLabel => 'Белки (г)';

  @override
  String get goalsFatLabel => 'Жиры (г)';

  @override
  String get goalsCarbsLabel => 'Углеводы (г)';

  @override
  String get goalsAgeLabel => 'Возраст';

  @override
  String get goalsWeightLabel => 'Вес (кг)';

  @override
  String get goalsHeightLabel => 'Рост (см)';

  @override
  String get goalsSaveButton => 'Сохранить';

  @override
  String get goalsSexMale => 'Мужской';

  @override
  String get goalsSexFemale => 'Женский';

  @override
  String get goalsActivitySedentary => 'Малоподвижный';

  @override
  String get goalsActivityLight => 'Лёгкая активность';

  @override
  String get goalsActivityModerate => 'Умеренная активность';

  @override
  String get goalsActivityHigh => 'Высокая активность';

  @override
  String get goalsGoalTypeLose => 'Похудение';

  @override
  String get goalsGoalTypeMaintain => 'Поддержание';

  @override
  String get goalsGoalTypeGain => 'Набор веса';

  @override
  String get goalsSexFieldLabel => 'Пол';

  @override
  String get goalsActivityFieldLabel => 'Образ жизни';

  @override
  String get goalsGoalTypeFieldLabel => 'Цель';

  @override
  String get goalsSexMaleDescription =>
      'Используется в формуле расчёта базового обмена веществ (коэффициент +5)';

  @override
  String get goalsSexFemaleDescription =>
      'Используется в формуле расчёта базового обмена веществ (коэффициент −161)';

  @override
  String get goalsActivitySedentaryDescription =>
      'Мало или нет физической активности, сидячая работа';

  @override
  String get goalsActivityLightDescription =>
      'Лёгкие тренировки 1–3 раза в неделю';

  @override
  String get goalsActivityModerateDescription =>
      'Умеренные тренировки 3–5 раз в неделю';

  @override
  String get goalsActivityHighDescription =>
      'Интенсивные тренировки 6–7 раз в неделю';

  @override
  String get goalsGoalTypeLoseDescription =>
      'Дефицит калорий для снижения веса';

  @override
  String get goalsGoalTypeMaintainDescription =>
      'Расход калорий на уровне нормы, вес остаётся прежним';

  @override
  String get goalsGoalTypeGainDescription =>
      'Профицит калорий для набора массы';

  @override
  String get addFoodTitle => 'Добавить еду';

  @override
  String get addFoodTabRecent => 'Недавние';

  @override
  String get addFoodTabSearch => 'Поиск';

  @override
  String get addFoodTabBarcode => 'Штрихкод';

  @override
  String get addFoodTabManual => 'Вручную';

  @override
  String get addFoodOnlyFavorites => 'Только избранное';

  @override
  String get addFoodNoFavoriteRecentFoods => 'Нет избранных недавних продуктов';

  @override
  String get addFoodNoRecentFoods => 'Нет недавних продуктов';

  @override
  String addFoodKcalPer100g(int kcal) {
    return '$kcal ккал / 100г';
  }

  @override
  String get addFoodFavoriteUpdateFailed => 'Не удалось обновить избранное';

  @override
  String get addFoodSearchLabel => 'Поиск продуктов';

  @override
  String get addFoodInYourFoodsSuffix => ' (в ваших продуктах)';

  @override
  String get addFoodBarcodeNotFound => 'Продукт не найден — введите вручную';

  @override
  String get addFoodAddManuallyButton => 'Добавить продукт вручную';

  @override
  String get addFoodSavedMessage => 'Продукт сохранён';

  @override
  String get addFoodDialogTitle => 'Информация о продукте';

  @override
  String get addFoodNameLabel => 'Название';

  @override
  String get addFoodKcalLabel => 'Ккал / 100г';

  @override
  String get addFoodProteinLabel => 'Белки / 100г';

  @override
  String get addFoodFatLabel => 'Жиры / 100г';

  @override
  String get addFoodCarbsLabel => 'Углеводы / 100г';

  @override
  String get addFoodGramsEatenLabel => 'Съедено, г';

  @override
  String get addFoodFavoriteLabel => 'Избранное';

  @override
  String get addFoodNutrientError =>
      'Значения нутриентов должны быть неотрицательными числами';

  @override
  String get addFoodNameRequiredError => 'Введите название продукта';

  @override
  String get addFoodCaloriesRequiredError =>
      'Калорийность должна быть больше нуля';

  @override
  String get addFoodGramsError =>
      'Съеденное количество должно быть положительным числом';

  @override
  String get addFoodCancelButton => 'Отмена';

  @override
  String get addFoodSaveButton => 'Сохранить';

  @override
  String get addFoodAddProductButton => 'Добавить продукт';

  @override
  String get addFoodAddProductDialogTitle => 'Новый продукт';

  @override
  String get addFoodNoProductsYet => 'Пока нет продуктов';

  @override
  String get addFoodNoSearchResults => 'Совпадений не найдено';

  @override
  String addFoodDeleteConfirmMessage(String name) {
    return 'Продукт $name будет удален! Подтвердить?';
  }

  @override
  String get addFoodDeleteConfirmButton => 'Удалить';

  @override
  String get dayNoMealsLoggedYet => 'Пока нет записей о приёмах пищи';

  @override
  String get dayLabelKcal => 'Ккал';

  @override
  String get dayLabelProtein => 'Белки';

  @override
  String get dayLabelFat => 'Жиры';

  @override
  String get dayLabelCarbs => 'Углев-ы';

  @override
  String dayMealSection(int number) {
    return 'Приём $number';
  }

  @override
  String dayEntryGrams(int grams) {
    return '$grams г';
  }

  @override
  String dayEntryKcal(int kcal) {
    return '$kcal ккал';
  }

  @override
  String get dayEntryMacroSuffix => 'Б/Ж/У';

  @override
  String get dayGramsEatenLabel => 'Съедено, г';

  @override
  String get dayCancelButton => 'Отмена';

  @override
  String get daySaveButton => 'Сохранить';
}
