import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';

abstract class ThemeRepository {
  Future<Either<Failure, ThemeModeOption>> getThemeMode();

  Future<Either<Failure, void>> setThemeMode(ThemeModeOption mode);
}
