import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDatasource _local;
  final Logger _logger = Logger();

  ThemeRepositoryImpl(this._local);

  @override
  Future<Either<Failure, ThemeModeOption>> getThemeMode() async {
    try {
      final value = _local.getThemeModeValue();
      return Right(ThemeModeOption.fromCode(value));
    } catch (e) {
      _logger.e('Failed to read theme mode preference: $e');
      return const Left(NetworkFailure('Failed to read theme mode preference'));
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeModeOption mode) async {
    try {
      await _local.setThemeModeValue(mode.code);
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to save theme mode preference: $e');
      return const Left(NetworkFailure('Failed to save theme mode preference'));
    }
  }
}
