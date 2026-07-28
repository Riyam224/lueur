import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/language/data/datasources/language_local_datasource.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/domain/repositories/language_repository.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageLocalDatasource _local;
  final Logger _logger = Logger();

  LanguageRepositoryImpl(this._local);

  @override
  Future<Either<Failure, AppLanguage>> getLanguage() async {
    try {
      final code = _local.getLanguageCode();
      return Right(AppLanguage.fromCode(code));
    } catch (e) {
      _logger.e('Failed to read language preference: $e');
      return const Left(NetworkFailure('Failed to read language preference'));
    }
  }

  @override
  Future<Either<Failure, void>> setLanguage(AppLanguage language) async {
    try {
      await _local.setLanguageCode(language.code);
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to save language preference: $e');
      return const Left(NetworkFailure('Failed to save language preference'));
    }
  }
}
