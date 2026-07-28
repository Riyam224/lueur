import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/language/data/datasources/language_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguageLocalDatasource', () {
    test('getLanguageCode returns null when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final datasource = LanguageLocalDatasource(prefs);

      expect(datasource.getLanguageCode(), isNull);
    });

    test('getLanguageCode returns null for an invalid stored value', () async {
      SharedPreferences.setMockInitialValues({
        LanguageLocalDatasource.preferenceKey: 'fr',
      });
      final prefs = await SharedPreferences.getInstance();
      final datasource = LanguageLocalDatasource(prefs);

      expect(datasource.getLanguageCode(), isNull);
    });

    test('setLanguageCode then getLanguageCode round-trips the value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final datasource = LanguageLocalDatasource(prefs);

      await datasource.setLanguageCode('ar');

      expect(datasource.getLanguageCode(), 'ar');
    });
  });
}
