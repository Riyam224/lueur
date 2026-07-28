import 'package:shared_preferences/shared_preferences.dart';

/// Wraps the single `preferred_language` preference key. [SharedPreferences]
/// is pre-fetched in `main()` (see `ThemeCubit`'s equivalent pre-opened-Hive-box
/// pattern) so reads here are synchronous.
class LanguageLocalDatasource {
  static const String preferenceKey = 'preferred_language';
  static const List<String> _validCodes = ['en', 'ar'];

  final SharedPreferences _prefs;

  LanguageLocalDatasource(this._prefs);

  /// Returns the stored language code, or `null` if missing or not one of
  /// the supported codes. Absence is never an error.
  String? getLanguageCode() {
    final stored = _prefs.getString(preferenceKey);
    if (stored == null || !_validCodes.contains(stored)) return null;
    return stored;
  }

  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(preferenceKey, code);
  }
}
