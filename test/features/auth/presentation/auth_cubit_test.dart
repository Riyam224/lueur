import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/preferences/auth_prefs.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';
import 'package:lueur/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/delete_account_usecase.dart';
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
  Future<Either<Failure, void>> Function()? logoutHandler;
  Either<Failure, void> deleteAccountResult = const Right(null);

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
  Future<Either<Failure, void>> logout() async {
    final handler = logoutHandler;
    if (handler != null) return handler();
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> checkSession() async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteAccount() async => deleteAccountResult;

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(
          {required String email,}) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> syncPreferredLanguage(
          String languageCode,) async =>
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
      deleteAccountUseCase: DeleteAccountUseCase(repository),
      onSessionCleared: () async {},
      onAccountDeleted: (_) async {},
    );
  });

  tearDown(() async {
    await cubit.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('AuthCubit marks the device as having authenticated', () {
    test('login success persists the hasEverAuthenticated flag before emitting',
        () async {
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
      await cubit.register(
          email: 'user@example.com', password: 'password123', name: 'User',);

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

  group('session clearing', () {
    test('logout waits for Firebase sign-out before clearing feature state',
        () async {
      final signOut = Completer<Either<Failure, void>>();
      repository.logoutHandler = () => signOut.future;
      var cleared = false;
      await cubit.close();
      cubit = AuthCubit(
        loginUseCase: LoginUseCase(repository),
        registerUseCase: RegisterUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
        checkSessionUseCase: CheckSessionUseCase(repository),
        deleteAccountUseCase: DeleteAccountUseCase(repository),
        onSessionCleared: () async => cleared = true,
        onAccountDeleted: (_) async {},
      );

      final logout = cubit.logout();
      await Future<void>.delayed(Duration.zero);
      expect(cleared, isFalse);

      signOut.complete(const Right(null));
      await logout;

      expect(cleared, isTrue);
      expect(cubit.state, isA<AuthUnauthenticated>());
    });

    test('guest entry waits for sign-out and emits an in-memory guest state',
        () async {
      final events = <String>[];
      repository.logoutHandler = () async {
        events.add('signed-out');
        return const Right(null);
      };
      await cubit.close();
      cubit = AuthCubit(
        loginUseCase: LoginUseCase(repository),
        registerUseCase: RegisterUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
        checkSessionUseCase: CheckSessionUseCase(repository),
        deleteAccountUseCase: DeleteAccountUseCase(repository),
        onSessionCleared: () async => events.add('cleared'),
        onAccountDeleted: (_) async {},
      );

      await cubit.enterGuestMode();

      expect(events, ['signed-out', 'cleared']);
      expect(cubit.state, isA<AuthGuest>());
    });
  });

  group('account deletion', () {
    test(
      'success wipes the deleted user\'s local data and lands unauthenticated',
      () async {
        final events = <String>[];
        await cubit.login(email: 'user@example.com', password: 'password123');
        expect(cubit.state, isA<AuthAuthenticated>());

        await cubit.close();
        cubit = AuthCubit(
          loginUseCase: LoginUseCase(repository),
          registerUseCase: RegisterUseCase(repository),
          logoutUseCase: LogoutUseCase(repository),
          signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
          checkSessionUseCase: CheckSessionUseCase(repository),
          deleteAccountUseCase: DeleteAccountUseCase(repository),
          onSessionCleared: () async {},
          onAccountDeleted: (userId) async => events.add('wiped:$userId'),
        );
        await cubit.login(email: 'user@example.com', password: 'password123');

        await cubit.deleteAccount();

        expect(events, ['wiped:uid-1']);
        expect(cubit.state, isA<AuthUnauthenticated>());
      },
    );

    test('failure emits AuthError and never wipes local data', () async {
      var wiped = false;
      await cubit.close();
      cubit = AuthCubit(
        loginUseCase: LoginUseCase(repository),
        registerUseCase: RegisterUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
        checkSessionUseCase: CheckSessionUseCase(repository),
        deleteAccountUseCase: DeleteAccountUseCase(repository),
        onSessionCleared: () async {},
        onAccountDeleted: (_) async => wiped = true,
      );
      await cubit.login(email: 'user@example.com', password: 'password123');
      repository.deleteAccountResult = const Left(ServerFailure('delete-account-failed'));

      await cubit.deleteAccount();

      expect(wiped, isFalse);
      expect(cubit.state, isA<AuthError>());
    });
  });
}
