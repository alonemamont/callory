import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _gapWindowMinutesKey = 'gap_window_minutes';
  static const defaultGapWindowMinutes = 90;

  final SharedPreferences prefs;
  SettingsService(this.prefs);

  Duration get gapWindow =>
      Duration(minutes: prefs.getInt(_gapWindowMinutesKey) ?? defaultGapWindowMinutes);

  Future<void> setGapWindowMinutes(int minutes) =>
      prefs.setInt(_gapWindowMinutesKey, minutes);
}
