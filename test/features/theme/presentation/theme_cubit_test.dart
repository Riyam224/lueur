import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/domain/repositories/theme_repository.dart';
import 'package:lueur/features/theme/domain/usecases/get_theme_mode_usecase.dart';
import 'package:lueur/features/theme/domain/usecases/set_theme_mode_usecase.dart';
import 'package:lueur/features/theme/presentation/cubit/theme_cubit.dart';

class FakeThemeRepository implements ThemeRepository {
  Either<Failure, ThemeModeOption> getResult =
      const Right(ThemeModeOption.system);
  Either<Failure, void> setResult = const Right(null);

  @override
  Future<Either<Failure, ThemeModeOption>> getThemeMode() async => getResult;

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeModeOption mode) async =>
      setResult;
}

ThemeCubit buildCubit(FakeThemeRepository repo) {
  return ThemeCubit(
    getThemeModeUseCase: GetThemeModeUseCase(repo),
    setThemeModeUseCase: SetThemeModeUseCase(repo),
  );
}

void main() {
  group('ThemeCubit', () {
    test('starts with system as the safe synchronous default', () async {
      final cubit = buildCubit(FakeThemeRepository());
      expect(cubit.state, ThemeModeOption.system);
      await cubit.close();
    });

    test('resolves to the persisted mode shortly after construction',
        () async {
      final repo = FakeThemeRepository()
        ..getResult = const Right(ThemeModeOption.dark);
      final cubit = buildCubit(repo);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, ThemeModeOption.dark);
      await cubit.close();
    });

    test('falls back to system when the initial read fails', () async {
      final repo = FakeThemeRepository()
        ..getResult = const Left(NetworkFailure('boom'));
      final cubit = buildCubit(repo);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, ThemeModeOption.system);
      await cubit.close();
    });

    test('setThemeMode emits the new mode on success', () async {
      final cubit = buildCubit(FakeThemeRepository());
      await Future<void>.delayed(Duration.zero);

      await cubit.setThemeMode(ThemeModeOption.dark);

      expect(cubit.state, ThemeModeOption.dark);
      await cubit.close();
    });

    test('setThemeMode does not change state when persistence fails',
        () async {
      final repo = FakeThemeRepository()
        ..setResult = const Left(NetworkFailure('boom'));
      final cubit = buildCubit(repo);
      await Future<void>.delayed(Duration.zero);

      await cubit.setThemeMode(ThemeModeOption.dark);

      expect(cubit.state, ThemeModeOption.system);
      await cubit.close();
    });

    test('does not emit after the cubit is closed (isClosed guard)',
        () async {
      final cubit = buildCubit(FakeThemeRepository());
      await cubit.close();

      expect(cubit.isClosed, isTrue);

      // Should not throw "emit after close" — the isClosed guard must hold.
      await cubit.setThemeMode(ThemeModeOption.dark);
    });

    test('toThemeMode maps each option to the matching Flutter ThemeMode',
        () {
      expect(ThemeModeOption.light.toThemeMode(), ThemeMode.light);
      expect(ThemeModeOption.dark.toThemeMode(), ThemeMode.dark);
      expect(ThemeModeOption.system.toThemeMode(), ThemeMode.system);
    });
  });
}
