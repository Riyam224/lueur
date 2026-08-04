import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/domain/repositories/theme_repository.dart';

class SetThemeModeUseCase {
  final ThemeRepository _repository;

  SetThemeModeUseCase(this._repository);

  Future<Either<Failure, void>> call(ThemeModeOption mode) =>
      _repository.setThemeMode(mode);
}
