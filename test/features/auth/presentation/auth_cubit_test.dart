import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/preferences/auth_prefs.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';
import 'package:lueur/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/login_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/register_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  Either<Failure, UserEntity> loginResult =
      const Right(UserEntity(id: 'uid-1', email: 'user@example.com'));
  Either<Failure, UserEntity> registerResult =
      const Right(UserEntity(id: 'uid-1', email: 'user@example.com'));
  Either<Failure, UserEntity> googleResult =
      const Right(UserEntity(id: 'uid-1', email: 'user@example.com'));

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async =>
      loginResult;

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async =>
      registerResult;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async => googleResult;

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity?>> checkSession() async => const Right(null);

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email}) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> syncPreferredLanguage(String languageCode) async =>
      const Right(null);
}

void main() {
  late Directory tempDir;
  late FakeAuthRepository repository;
  late AuthCubit cubit;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auth_cubit_test');
    Hive.init(tempDir.path);

    repository = FakeAuthRepository();
    cubit = AuthCubit(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
      checkSessionUseCase: CheckSessionUseCase(repository),
      onLogout: () {},
    );
  });

  tearDown(() async {
    await cubit.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('AuthCubit marks the device as having authenticated', () {
    test('login success persists the hasEverAuthenticated flag before emitting', () async {
      expect(await AuthPrefs.hasEverAuthenticated(), isFalse);

      await cubit.login(email: 'user@example.com', password: 'password123');

      expect(cubit.state, isA<AuthAuthenticated>());
      expect(await AuthPrefs.hasEverAuthenticated(), isTrue);
    });

    test('login failure does not persist the flag', () async {
      repository.loginResult = const Left(ServerFailure('nope'));

      await cubit.login(email: 'user@example.com', password: 'wrong');

      expect(cubit.state, isA<AuthError>());
      expect(await AuthPrefs.hasEverAuthenticated(), isFalse);
    });

    test('register success persists the flag', () async {
      await cubit.register(email: 'user@example.com', password: 'password123', name: 'User');

      expect(cubit.state, isA<AuthAuthenticated>());
      expect(await AuthPrefs.hasEverAuthenticated(), isTrue);
    });

    test('Google sign-in success persists the flag', () async {
      await cubit.signInWithGoogle();

      expect(cubit.state, isA<AuthAuthenticated>());
      expect(await AuthPrefs.hasEverAuthenticated(), isTrue);
    });

    test('Google sign-in cancellation does not persist the flag', () async {
      repository.googleResult = const Left(CancellationFailure());

      await cubit.signInWithGoogle();

      expect(cubit.state, isA<AuthInitial>());
      expect(await AuthPrefs.hasEverAuthenticated(), isFalse);
    });
  });
}
