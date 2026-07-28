import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/domain/repositories/language_repository.dart';
import 'package:lueur/features/language/domain/usecases/get_language_preference_usecase.dart';

class FakeLanguageRepository implements LanguageRepository {
  Either<Failure, AppLanguage> getResult = const Right(AppLanguage.en);

  @override
  Future<Either<Failure, AppLanguage>> getLanguage() async => getResult;

  @override
  Future<Either<Failure, void>> setLanguage(AppLanguage language) async =>
      const Right(null);
}

void main() {
  group('GetLanguagePreferenceUseCase', () {
    test('delegates to repository.getLanguage and returns its result', () async {
      final repo = FakeLanguageRepository()
        ..getResult = const Right(AppLanguage.ar);
      final useCase = GetLanguagePreferenceUseCase(repo);

      final result = await useCase();

      expect(result, const Right<Object, AppLanguage>(AppLanguage.ar));
    });

    test('propagates a Left failure from the repository', () async {
      final repo = FakeLanguageRepository()
        ..getResult = const Left(NetworkFailure('boom'));
      final useCase = GetLanguagePreferenceUseCase(repo);

      final result = await useCase();

      expect(result.isLeft(), isTrue);
    });
  });
}
