import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _gapWindowMinutesKey = 'gap_window_minutes';
  static const _localeCodeKey = 'locale_code';
  static const _lastSearchQueryKey = 'last_search_query';
  static const _lastManualSearchQueryKey = 'last_manual_search_query';
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

  String get lastSearchQuery => prefs.getString(_lastSearchQueryKey) ?? '';

  Future<void> setLastSearchQuery(String query) =>
      prefs.setString(_lastSearchQueryKey, query);

  String get lastManualSearchQuery =>
      prefs.getString(_lastManualSearchQueryKey) ?? '';

  Future<void> setLastManualSearchQuery(String query) =>
      prefs.setString(_lastManualSearchQueryKey, query);
}
