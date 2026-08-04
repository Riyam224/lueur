import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:lueur/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ThemeRepositoryImpl> buildRepo(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return ThemeRepositoryImpl(ThemeLocalDatasource(prefs));
  }

  group('ThemeRepositoryImpl', () {
    test('getThemeMode resolves Right(system) when nothing is stored',
        () async {
      final repo = await buildRepo({});

      final result = await repo.getThemeMode();

      expect(
        result,
        const Right<Object, ThemeModeOption>(ThemeModeOption.system),
      );
    });

    test('getThemeMode resolves Right(dark) when "dark" is stored', () async {
      final repo = await buildRepo({
        ThemeLocalDatasource.preferenceKey: 'dark',
      });

      final result = await repo.getThemeMode();

      expect(
        result,
        const Right<Object, ThemeModeOption>(ThemeModeOption.dark),
      );
    });

    test('setThemeMode persists the value and resolves Right(null)',
        () async {
      final repo = await buildRepo({});

      final setResult = await repo.setThemeMode(ThemeModeOption.light);
      final getResult = await repo.getThemeMode();

      expect(setResult.isRight(), isTrue);
      expect(
        getResult,
        const Right<Object, ThemeModeOption>(ThemeModeOption.light),
      );
    });
  });
}
