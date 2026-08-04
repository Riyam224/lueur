import 'package:shared_preferences/shared_preferences.dart';

/// Wraps the single `theme_mode` preference key.
class ThemeLocalDatasource {
  static const String preferenceKey = 'theme_mode';
  static const List<String> _validValues = ['light', 'dark', 'system'];

  final SharedPreferences _prefs;

  ThemeLocalDatasource(this._prefs);

  /// Returns the stored theme mode value, or `null` if missing or not one
  /// of the supported values. Absence is never an error.
  String? getThemeModeValue() {
    final stored = _prefs.getString(preferenceKey);
    if (stored == null || !_validValues.contains(stored)) return null;
    return stored;
  }

  Future<void> setThemeModeValue(String value) async {
    await _prefs.setString(preferenceKey, value);
  }
}
