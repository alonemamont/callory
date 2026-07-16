import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/data/settings_service.dart';

void main() {
  test('defaults to 90 minutes when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    expect(service.gapWindow, const Duration(minutes: 90));
  });

  test('setGapWindowMinutes persists and is reflected immediately', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    await service.setGapWindowMinutes(45);

    expect(service.gapWindow, const Duration(minutes: 45));
  });

  test('localeCode defaults to null when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    expect(service.localeCode, isNull);
  });

  test('setLocaleCode persists and is reflected immediately', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    await service.setLocaleCode('ru');

    expect(service.localeCode, 'ru');
  });

  test('setLocaleCode(null) clears a previously stored locale', () async {
    SharedPreferences.setMockInitialValues({'locale_code': 'ru'});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsService(prefs);

    await service.setLocaleCode(null);

    expect(service.localeCode, isNull);
  });
}
