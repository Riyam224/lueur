import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';
import 'package:lueur/features/auth/domain/usecases/sync_preferred_language_usecase.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/domain/repositories/language_repository.dart';
import 'package:lueur/features/language/domain/usecases/get_language_preference_usecase.dart';
import 'package:lueur/features/language/domain/usecases/set_language_preference_usecase.dart';
import 'package:lueur/features/language/presentation/cubit/language_cubit.dart';

class FakeLanguageRepository implements LanguageRepository {
  Either<Failure, AppLanguage> getResult = const Right(AppLanguage.en);
  Either<Failure, void> setResult = const Right(null);

  @override
  Future<Either<Failure, AppLanguage>> getLanguage() async => getResult;

  @override
  Future<Either<Failure, void>> setLanguage(AppLanguage language) async =>
      setResult;
}

class FakeAuthRepository implements AuthRepository {
  Either<Failure, void> syncResult = const Right(null);

  @override
  Future<Either<Failure, void>> syncPreferredLanguage(
    String languageCode,
  ) async =>
      syncResult;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() async => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity?>> checkSession() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteAccount() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async =>
      throw UnimplementedError();
}

LanguageCubit buildCubit(
  FakeLanguageRepository repo, {
  FakeAuthRepository? authRepo,
}) {
  return LanguageCubit(
    getLanguagePreferenceUseCase: GetLanguagePreferenceUseCase(repo),
    setLanguagePreferenceUseCase: SetLanguagePreferenceUseCase(repo),
    syncPreferredLanguageUseCase:
        SyncPreferredLanguageUseCase(authRepo ?? FakeAuthRepository()),
  );
}

void main() {
  group('LanguageCubit', () {
    test('starts with English as the safe synchronous default', () async {
      final cubit = buildCubit(FakeLanguageRepository());
      expect(cubit.state, const Locale('en'));
      await cubit.close();
    });

    test('resolves to the persisted language shortly after construction', () async {
      final repo = FakeLanguageRepository()
        ..getResult = const Right(AppLanguage.ar);
      final cubit = buildCubit(repo);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, const Locale('ar'));
      await cubit.close();
    });

    test('falls back to English when the initial read fails', () async {
      final repo = FakeLanguageRepository()
        ..getResult = const Left(NetworkFailure('boom'));
      final cubit = buildCubit(repo);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, const Locale('en'));
      await cubit.close();
    });

    test('changeLanguage emits the new locale on success', () async {
      final cubit = buildCubit(FakeLanguageRepository());
      await Future<void>.delayed(Duration.zero);

      await cubit.changeLanguage(AppLanguage.ar);

      expect(cubit.state, const Locale('ar'));
      await cubit.close();
    });

    test('changeLanguage does not change state when persistence fails', () async {
      final repo = FakeLanguageRepository()
        ..setResult = const Left(NetworkFailure('boom'));
      final cubit = buildCubit(repo);
      await Future<void>.delayed(Duration.zero);

      await cubit.changeLanguage(AppLanguage.ar);

      expect(cubit.state, const Locale('en'));
      await cubit.close();
    });

    test('does not emit after the cubit is closed (isClosed guard)', () async {
      final cubit = buildCubit(FakeLanguageRepository());
      await cubit.close();

      expect(cubit.isClosed, isTrue);

      // Should not throw "emit after close" — the isClosed guard must hold.
      await cubit.changeLanguage(AppLanguage.ar);
    });
  });
}
