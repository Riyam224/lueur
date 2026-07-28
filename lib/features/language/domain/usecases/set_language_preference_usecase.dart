import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/domain/repositories/language_repository.dart';

class SetLanguagePreferenceUseCase {
  final LanguageRepository _repository;

  SetLanguagePreferenceUseCase(this._repository);

  Future<Either<Failure, void>> call(AppLanguage language) =>
      _repository.setLanguage(language);
}
