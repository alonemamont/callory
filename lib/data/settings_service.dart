import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _gapWindowMinutesKey = 'gap_window_minutes';
  static const _localeCodeKey = 'locale_code';
  static const defaultGapWindowMinutes = 90;

  final SharedPreferences prefs;
  SettingsService(this.prefs);

  Duration get gapWindow =>
      Duration(minutes: prefs.getInt(_gapWindowMinutesKey) ?? defaultGapWindowMinutes);

  Future<void> setGapWindowMinutes(int minutes) =>
      prefs.setInt(_gapWindowMinutesKey, minutes);

  String? get localeCode => prefs.getString(_localeCodeKey);

  Future<void> setLocaleCode(String? code) {
    if (code == null) return prefs.remove(_localeCodeKey);
    return prefs.setString(_localeCodeKey, code);
  }
}
