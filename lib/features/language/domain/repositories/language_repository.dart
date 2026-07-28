import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';

abstract class LanguageRepository {
  Future<Either<Failure, AppLanguage>> getLanguage();

  Future<Either<Failure, void>> setLanguage(AppLanguage language);
}
