import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/domain/repositories/language_repository.dart';
import 'package:lueur/features/language/domain/usecases/set_language_preference_usecase.dart';

class FakeLanguageRepository implements LanguageRepository {
  AppLanguage? lastSet;
  Either<Failure, void> setResult = const Right(null);

  @override
  Future<Either<Failure, AppLanguage>> getLanguage() async =>
      const Right(AppLanguage.en);

  @override
  Future<Either<Failure, void>> setLanguage(AppLanguage language) async {
    lastSet = language;
    return setResult;
  }
}

void main() {
  group('SetLanguagePreferenceUseCase', () {
    test('delegates to repository.setLanguage with the given language', () async {
      final repo = FakeLanguageRepository();
      final useCase = SetLanguagePreferenceUseCase(repo);

      final result = await useCase(AppLanguage.ar);

      expect(repo.lastSet, AppLanguage.ar);
      expect(result.isRight(), isTrue);
    });

    test('propagates a Left failure from the repository', () async {
      final repo = FakeLanguageRepository()
        ..setResult = const Left(NetworkFailure('boom'));
      final useCase = SetLanguagePreferenceUseCase(repo);

      final result = await useCase(AppLanguage.ar);

      expect(result.isLeft(), isTrue);
    });
  });
}
