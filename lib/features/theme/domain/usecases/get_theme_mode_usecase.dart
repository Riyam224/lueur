import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/domain/repositories/theme_repository.dart';

class GetThemeModeUseCase {
  final ThemeRepository _repository;

  GetThemeModeUseCase(this._repository);

  Future<Either<Failure, ThemeModeOption>> call() => _repository.getThemeMode();
}
