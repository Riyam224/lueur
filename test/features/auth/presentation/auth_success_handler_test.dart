import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/preferences/age_confirmation_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_theme.dart';
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
import 'package:lueur/features/auth/presentation/utils/auth_success_handler.dart';
import 'package:lueur/l10n/app_localizations.dart';

class _FakeAuthRepository implements AuthRepository {
  bool deleteAccountCalled = false;
  Either<Failure, void> deleteAccountResult = const Right(null);

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    deleteAccountCalled = true;
    return deleteAccountResult;
  }

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, AuthResult>> register({
    required String email,
    required String password,
    required String name,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthResult>> signInWithGoogle() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity?>> checkSession() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> syncPreferredLanguage(String languageCode) =>
      throw UnimplementedError();
}

void main() {
  late Directory tempDir;
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  const uid = 'uid-1';
  const user = UserEntity(id: uid, email: 'user@example.com');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auth_success_handler_test');
    Hive.init(tempDir.path);
    // Pre-opens the boxes handleAuthSuccess touches so its internal
    // Hive.openBox calls resolve from the already-open in-memory registry
    // instead of hitting real file I/O — real dart:io async work started
    // inside a testWidgets body's zone never resolves under plain pump().
    await Hive.openBox<bool>('age_confirmation');
    await Hive.openBox<bool>('onboarding');

    repo = _FakeAuthRepository();
    cubit = AuthCubit(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(repo),
      checkSessionUseCase: CheckSessionUseCase(repo),
      deleteAccountUseCase: DeleteAccountUseCase(repo),
      onSessionCleared: () async {},
      onAccountDeleted: (_) async {},
    );
  });

  tearDown(() async {
    await cubit.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  Widget buildApp(
    AuthAuthenticated state, {
    required List<String> visitedRoutes,
    bool preConfirmedAge = false,
  }) {
    final router = GoRouter(
      initialLocation: '/trigger',
      routes: [
        GoRoute(
          path: '/trigger',
          builder: (context, _) => Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => handleAuthSuccess(
                    context,
                    state,
                    preConfirmedAge: preConfirmedAge,
                  ),
                  child: const Text('Trigger'),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, _) {
            visitedRoutes.add(AppRoutes.home);
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
        GoRoute(
          path: AppRoutes.onBoarding,
          builder: (context, _) {
            visitedRoutes.add(AppRoutes.onBoarding);
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ],
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets(
    'a new, unconfirmed account is blocked by the modal and rolled back on decline',
    (tester) async {
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(const AuthAuthenticated(user, isNewUser: true), visitedRoutes: visitedRoutes),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text("I'm not 18"), findsOneWidget);
      await tester.tap(find.text("I'm not 18"));
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(repo.deleteAccountCalled, isTrue);
      expect(visitedRoutes, isEmpty);
      expect(await AgeConfirmationPrefs.hasConfirmedAge(uid), isFalse);
    },
  );

  testWidgets(
    'a new account confirming the modal is marked and navigation proceeds',
    (tester) async {
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(const AuthAuthenticated(user, isNewUser: true), visitedRoutes: visitedRoutes),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(find.text("I'm 18 or older"));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      // Build the success dialog before waiting for its auto-dismiss timer.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(repo.deleteAccountCalled, isFalse);
      expect(await AgeConfirmationPrefs.hasConfirmedAge(uid), isTrue);
      expect(visitedRoutes, [AppRoutes.onBoarding]);
    },
  );

  testWidgets(
    'a new account that already confirmed age on a prior sign-in skips the modal',
    (tester) async {
      await AgeConfirmationPrefs.markAgeConfirmed(uid);
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(const AuthAuthenticated(user, isNewUser: true), visitedRoutes: visitedRoutes),
      );

      await tester.runAsync(() async {
        await tester.tap(find.text('Trigger'));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text("I'm 18 or older"), findsNothing);
      expect(visitedRoutes, [AppRoutes.onBoarding]);
    },
  );

  testWidgets(
    'a returning (non-new) account skips the modal entirely',
    (tester) async {
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(const AuthAuthenticated(user), visitedRoutes: visitedRoutes),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text("I'm 18 or older"), findsNothing);
      expect(visitedRoutes, [AppRoutes.onBoarding]);
    },
  );

  testWidgets(
    'preConfirmedAge marks the flag without showing the modal, for the '
    'checkbox-gated email/password register path',
    (tester) async {
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(
          const AuthAuthenticated(user, isNewUser: true),
          visitedRoutes: visitedRoutes,
          preConfirmedAge: true,
        ),
      );

      await tester.runAsync(() async {
        await tester.tap(find.text('Trigger'));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text("I'm 18 or older"), findsNothing);
      expect(await AgeConfirmationPrefs.hasConfirmedAge(uid), isTrue);
      expect(visitedRoutes, [AppRoutes.onBoarding]);
    },
  );
}
