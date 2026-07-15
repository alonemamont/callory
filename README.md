# <img src="web/favicon.png" alt="Callory logo" width="28" /> Callory

Офлайн-first трекер калорий на Flutter с локальным хранением в SQLite, добавлением еды по штрихкоду или вручную, дневными целями по макросам и резервным копированием/восстановлением через JSON.

## О проекте

Callory — это трекер питания для одного устройства, написанный на Flutter. Он хранит данные дневника локально, работает без бэкенда и использует Open Food Facts только для поиска по штрихкоду и названию, когда есть сеть.

Сейчас приложение поддерживает:

- Дневник питания с группировкой по приемам пищи
- Добавление еды по штрихкоду, через поиск или вручную
- Дневные цели по калориям и макронутриентам
- Настраиваемый интервал группировки приемов пищи
- Экспорт и импорт JSON для полного восстановления локальных данных

## Стек

- Flutter
- Dart `^3.12.2`
- Riverpod для управления состоянием
- Drift + SQLite для локального хранения
- Open Food Facts для внешнего поиска продуктов

## Быстрый старт

### Требования

- Установленный Flutter SDK, доступный в `PATH`
- Устройство или эмулятор для целевой платформы
- Платформенные toolchain-компоненты только для тех целей, которые вы собираете локально:
  - Android: Android Studio / Android SDK
  - iOS/macOS: Xcode
  - Windows: Visual Studio с workload `Desktop development with C++`
  - Linux: зависимости Flutter для Linux desktop

> [!NOTE]
> В репозитории уже есть сгенерированный код Drift в `lib/db/database.g.dart`. Генерация нужна только при изменении схемы базы или Drift-аннотаций.

### Установка зависимостей

```bash
flutter pub get
```

### Запуск приложения

Запустите приложение на любой подключенной цели:

```bash
flutter run
```

Примеры:

```bash
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d windows
flutter run -d linux
flutter run -d macos
```

Чтобы посмотреть список доступных устройств:

```bash
flutter devices
```

## Сборка

Основные release-сборки:

```bash
flutter build apk
flutter build appbundle
flutter build ios
flutter build web
flutter build windows
flutter build linux
flutter build macos
```

## Процесс разработки

### Запуск тестов

```bash
flutter test
```

### Статический анализ

```bash
flutter analyze
```

### Перегенерация файлов Drift

Запускайте это только после изменений в файлах вроде `lib/db/database.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Структура проекта

```text
lib/
  data/         репозитории и внешние интеграции
  db/           схема Drift и сгенерированный код базы
  domain/       бизнес-правила и вычисления
  providers/    конфигурация Riverpod
  ui/           экраны и виджеты
test/
  data/         тесты репозиториев и интеграционные проверки
  domain/       unit-тесты бизнес-логики
  ui/           widget-тесты
```

## Локальная модель данных

- Все пользовательские данные хранятся локально в SQLite
- Нет бэкенда, аккаунтов и облачной синхронизации
- Запросы по штрихкоду и поиску уходят в Open Food Facts только при наличии сети
- Экспорт и импорт используют JSON, а импорт полностью заменяет локальные данные

## Заметки для разработки

- Основная точка входа: `lib/main.dart`
- Версия схемы базы задается в `lib/db/database.dart`
- В проекте есть платформенные директории для Android, iOS, web, Windows, Linux и macOS
