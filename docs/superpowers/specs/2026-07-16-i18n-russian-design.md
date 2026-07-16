# i18n / Russian localization — design

## Goal

Add multi-language support as a first-class feature (infra extensible to more locales later) and fully implement Russian as the second supported language, alongside English.

## Approach

Official Flutter localization toolchain: `flutter_localizations` + `intl`, ARB source files, codegen'd `AppLocalizations` class (`flutter gen-l10n`, `flutter: generate: true` in `pubspec.yaml`). Chosen over `easy_localization` (extra runtime dep, less type-safe) and a hand-rolled `Map<String,String>` (no tooling, no ICU/pluralization support) because the app is small (~47 strings, 4 screens) and gen-l10n is zero-extra-dependency, type-safe, and the Flutter-standard path — worth the one-time codegen setup.

## Default locale behavior

On first launch, app follows device locale (Russian device → Russian UI; anything else → English fallback). User can override in Settings; override persists and takes priority over system locale on subsequent launches.

## Architecture

### Dependencies & config
- `pubspec.yaml`: add `flutter_localizations` (sdk: flutter) and `intl` to `dependencies`; add `flutter: generate: true`.
- New `l10n.yaml` at repo root: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `output-class: AppLocalizations`.

### Translation sources
- `lib/l10n/app_en.arb` — template/source-of-truth for keys, placeholders, descriptions. Covers every user-facing string in the app (~47 strings from `add_food_screen.dart`, `goals_screen.dart`, `settings_screen.dart`, `day_screen.dart`, `number_field.dart`, plus nav labels in `main.dart`).
- `lib/l10n/app_ru.arb` — full Russian translation of every key in the template.

### State & persistence
Mirrors the existing `SettingsService` pattern (plain wrapper class over `SharedPreferences`, one key per setting) — no new abstraction introduced.

- `lib/data/settings_service.dart`: add `String? get localeCode` / `set localeCode(String? code)` backed by a new SharedPreferences key `'locale_code'`. `null` means "follow system locale".
- `lib/providers/providers.dart`: add `localeProvider`, a `NotifierProvider<LocaleNotifier, Locale?>`. Initial state read from `settingsServiceProvider.localeCode` (parsed to `Locale`, or `null`). Exposes `setLocale(Locale? locale)` which updates provider state and writes through to `SettingsService.localeCode`.
- `lib/main.dart`: `CalloryApp`'s `MaterialApp` watches `localeProvider` and passes it to `locale:` (Flutter falls back to system-locale negotiation against `supportedLocales` when `null`). Add `localizationsDelegates: AppLocalizations.localizationsDelegates` (plus the standard `GlobalMaterialLocalizations.delegate` etc., which `AppLocalizations.localizationsDelegates` already bundles) and `supportedLocales: AppLocalizations.supportedLocales`.

### UI changes
- `lib/ui/settings/settings_screen.dart`: add a `ListTile` ("Language" / "Язык") that opens a simple picker (System / English / Русский) and calls `ref.read(localeProvider.notifier).setLocale(...)`.
- Every hardcoded `Text('...')` (and any hardcoded strings in `SnackBar`s, dialog titles/buttons, form labels) across the 4 screens, `number_field.dart`, and nav labels in `main.dart` is replaced with `AppLocalizations.of(context)!.keyName`, with matching entries added to both ARB files.

## Testing

The 4 existing widget test files (`test/ui/settings_screen_test.dart`, `goals_screen_test.dart`, `day_screen_test.dart`, `add_food_screen_test.dart`) build a bare `MaterialApp(home: X)` and assert against literal English strings via `find.text('...')`. Once screens read strings through `AppLocalizations.of(context)!`, these will throw a null-check error because the bare `MaterialApp` has no localization delegates registered.

Fix: add a small test helper (e.g. `test/test_helpers.dart` — `Widget wrapWithLocalizations(Widget child)`) that wraps the child in a `MaterialApp` with `localizationsDelegates: AppLocalizations.localizationsDelegates` and `supportedLocales: AppLocalizations.supportedLocales`. Update the 4 test files to use it instead of bare `MaterialApp`. `flutter_test` defaults the test locale to `en`, so existing English `find.text(...)` assertions keep passing unmodified.

## Out of scope

- RTL layout support.
- Pluralization/ICU beyond what gen-l10n provides for free (e.g. `{count, plural, ...}` used only where a string already needs it — no new plural-heavy strings introduced solely for this feature).
- Languages beyond English/Russian (infra is built so adding another ARB file + `supportedLocales` entry is trivial later, but no other language is translated now).
