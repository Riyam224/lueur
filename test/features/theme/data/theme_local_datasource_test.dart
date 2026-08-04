import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeLocalDatasource', () {
    test('getThemeModeValue returns null when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final datasource = ThemeLocalDatasource(prefs);

      expect(datasource.getThemeModeValue(), isNull);
    });

    test('getThemeModeValue returns null for an invalid stored value',
        () async {
      SharedPreferences.setMockInitialValues({
        ThemeLocalDatasource.preferenceKey: 'sepia',
      });
      final prefs = await SharedPreferences.getInstance();
      final datasource = ThemeLocalDatasource(prefs);

      expect(datasource.getThemeModeValue(), isNull);
    });

    test('setThemeModeValue then getThemeModeValue round-trips the value',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final datasource = ThemeLocalDatasource(prefs);

      await datasource.setThemeModeValue('dark');

      expect(datasource.getThemeModeValue(), 'dark');
    });
  });
}
