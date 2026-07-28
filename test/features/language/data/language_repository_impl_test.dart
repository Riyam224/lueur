import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/language/data/datasources/language_local_datasource.dart';
import 'package:lueur/features/language/data/repositories/language_repository_impl.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LanguageRepositoryImpl> buildRepo(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return LanguageRepositoryImpl(LanguageLocalDatasource(prefs));
  }

  group('LanguageRepositoryImpl', () {
    test('getLanguage resolves Right(en) when nothing is stored', () async {
      final repo = await buildRepo({});

      final result = await repo.getLanguage();

      expect(result, const Right<Object, AppLanguage>(AppLanguage.en));
    });

    test('getLanguage resolves Right(ar) when "ar" is stored', () async {
      final repo = await buildRepo({
        LanguageLocalDatasource.preferenceKey: 'ar',
      });

      final result = await repo.getLanguage();

      expect(result, const Right<Object, AppLanguage>(AppLanguage.ar));
    });

    test('setLanguage persists the value and resolves Right(null)', () async {
      final repo = await buildRepo({});

      final setResult = await repo.setLanguage(AppLanguage.ar);
      final getResult = await repo.getLanguage();

      expect(setResult.isRight(), isTrue);
      expect(getResult, const Right<Object, AppLanguage>(AppLanguage.ar));
    });
  });
}
