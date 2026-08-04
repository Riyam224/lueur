import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/domain/repositories/theme_repository.dart';
import 'package:lueur/features/theme/domain/usecases/get_theme_mode_usecase.dart';

class FakeThemeRepository implements ThemeRepository {
  Either<Failure, ThemeModeOption> getResult =
      const Right(ThemeModeOption.system);

  @override
  Future<Either<Failure, ThemeModeOption>> getThemeMode() async => getResult;

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeModeOption mode) async =>
      const Right(null);
}

void main() {
  group('GetThemeModeUseCase', () {
    test('delegates to repository.getThemeMode and returns its result',
        () async {
      final repo = FakeThemeRepository()
        ..getResult = const Right(ThemeModeOption.dark);
      final useCase = GetThemeModeUseCase(repo);

      final result = await useCase();

      expect(
        result,
        const Right<Object, ThemeModeOption>(ThemeModeOption.dark),
      );
    });

    test('propagates a Left failure from the repository', () async {
      final repo = FakeThemeRepository()
        ..getResult = const Left(NetworkFailure('boom'));
      final useCase = GetThemeModeUseCase(repo);

      final result = await useCase();

      expect(result.isLeft(), isTrue);
    });
  });
}
