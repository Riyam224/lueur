import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/domain/repositories/theme_repository.dart';
import 'package:lueur/features/theme/domain/usecases/set_theme_mode_usecase.dart';

class FakeThemeRepository implements ThemeRepository {
  ThemeModeOption? lastSet;
  Either<Failure, void> setResult = const Right(null);

  @override
  Future<Either<Failure, ThemeModeOption>> getThemeMode() async =>
      const Right(ThemeModeOption.system);

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeModeOption mode) async {
    lastSet = mode;
    return setResult;
  }
}

void main() {
  group('SetThemeModeUseCase', () {
    test('delegates to repository.setThemeMode with the given mode',
        () async {
      final repo = FakeThemeRepository();
      final useCase = SetThemeModeUseCase(repo);

      final result = await useCase(ThemeModeOption.dark);

      expect(repo.lastSet, ThemeModeOption.dark);
      expect(result.isRight(), isTrue);
    });

    test('propagates a Left failure from the repository', () async {
      final repo = FakeThemeRepository()
        ..setResult = const Left(NetworkFailure('boom'));
      final useCase = SetThemeModeUseCase(repo);

      final result = await useCase(ThemeModeOption.dark);

      expect(result.isLeft(), isTrue);
    });
  });
}
