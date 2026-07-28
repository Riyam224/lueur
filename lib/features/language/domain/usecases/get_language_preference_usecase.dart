import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/domain/repositories/language_repository.dart';

class GetLanguagePreferenceUseCase {
  final LanguageRepository _repository;

  GetLanguagePreferenceUseCase(this._repository);

  Future<Either<Failure, AppLanguage>> call() => _repository.getLanguage();
}
