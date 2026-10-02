import 'dart:async';
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
import 'package:lueur/core/preferences/onboarding_prefs.dart';
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

  // handleAuthSuccess makes Hive writes from inside the fake-async zone, so
  // Hive's internal write-lock futures belong to that zone — closing the box
  // needs fake-zone pumps too, or tearDown's Hive.deleteFromDisk() waits
  // forever once the body has ended.
  Future<void> closeHive(WidgetTester tester) async {
    var closed = false;
    unawaited(Hive.close().then((_) => closed = true));
    for (var spins = 0; !closed && spins < 100; spins++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    if (!closed) fail('Hive did not close within 100 spins');
  }

  // Lets Hive file I/O started in the fake-async zone complete in real time,
  // pumping between waits so its fake-zone continuations run.
  Future<void> letHiveIoComplete(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
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

      await closeHive(tester);
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

      await closeHive(tester);
    },
  );

  testWidgets(
    'a new account that already confirmed age on a prior sign-in skips the modal',
    (tester) async {
      // Seeded outside the fake-async zone so its file I/O can complete.
      await tester.runAsync(() => AgeConfirmationPrefs.markAgeConfirmed(uid));
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(const AuthAuthenticated(user, isNewUser: true), visitedRoutes: visitedRoutes),
      );

      // Tapped outside runAsync so the success dialog's auto-dismiss timer
      // runs on the fake clock that pump(1500ms) advances.
      await tester.tap(find.text('Trigger'));
      await letHiveIoComplete(tester);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      await letHiveIoComplete(tester);

      expect(find.text("I'm 18 or older"), findsNothing);
      expect(visitedRoutes, [AppRoutes.onBoarding]);

      await closeHive(tester);
    },
  );

  Future<void> runReturningLogin(
    WidgetTester tester,
    List<String> visitedRoutes, {
    String loginUid = uid,
  }) async {
    await tester.pumpWidget(
      buildApp(
        AuthAuthenticated(UserEntity(id: loginUid, email: 'u@example.com')),
        visitedRoutes: visitedRoutes,
      ),
    );
    await tester.tap(find.text('Trigger'));
    await letHiveIoComplete(tester);
    // pumpAndSettle alone doesn't reach the dialog's auto-dismiss timer.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await letHiveIoComplete(tester);
  }

  testWidgets(
    'a returning (non-new) account skips the modal and goes straight Home',
    (tester) async {
      final visitedRoutes = <String>[];
      await runReturningLogin(tester, visitedRoutes);

      expect(find.text("I'm 18 or older"), findsNothing);
      expect(visitedRoutes, [AppRoutes.home]);

      await closeHive(tester);
    },
  );

  testWidgets(
    'a returning account with no seen_<uid> and no pending goes Home, '
    'records seen_<uid> and leaves no pending',
    (tester) async {
      final visitedRoutes = <String>[];
      await runReturningLogin(tester, visitedRoutes);

      final box = Hive.box<bool>('onboarding');
      expect(visitedRoutes, [AppRoutes.home]);
      expect(box.get('seen_$uid'), isTrue);
      expect(box.containsKey('pending'), isFalse);
      expect(box.containsKey('seen'), isFalse);

      await closeHive(tester);
    },
  );

  testWidgets(
    'a returning account with a pending left by another account goes Home, '
    'clears it, and a later brand-new account still sees onboarding',
    (tester) async {
      await tester.runAsync(OnboardingPrefs.markSeen);
      final visitedRoutes = <String>[];
      await runReturningLogin(tester, visitedRoutes);

      final box = Hive.box<bool>('onboarding');
      expect(visitedRoutes, [AppRoutes.home]);
      expect(box.containsKey('pending'), isFalse);

      final newAccountSeen = await tester
          .runAsync(() => OnboardingPrefs.hasSeen('brand-new-uid'));
      expect(newAccountSeen, isFalse);

      await closeHive(tester);
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

      // Tapped outside runAsync so the success dialog's auto-dismiss timer
      // runs on the fake clock that pump(1500ms) advances.
      await tester.tap(find.text('Trigger'));
      await letHiveIoComplete(tester);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      await letHiveIoComplete(tester);

      expect(find.text("I'm 18 or older"), findsNothing);
      expect(await AgeConfirmationPrefs.hasConfirmedAge(uid), isTrue);
      expect(visitedRoutes, [AppRoutes.onBoarding]);

      await closeHive(tester);
    },
  );

  // Splash -> Onboarding -> Register -> Home: onboarding already finished
  // (pending), then a brand-new account signs up and must not see it again.
  testWidgets(
    'new email/password sign-up after onboarding ends on Home with no '
    'second onboarding',
    (tester) async {
      await tester.runAsync(OnboardingPrefs.markSeen);
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(
          const AuthAuthenticated(user, isNewUser: true),
          visitedRoutes: visitedRoutes,
          preConfirmedAge: true,
        ),
      );
      await tester.tap(find.text('Trigger'));
      await letHiveIoComplete(tester);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      await letHiveIoComplete(tester);

      expect(visitedRoutes, [AppRoutes.home]);
      expect(Hive.box<bool>('onboarding').get('seen_$uid'), isTrue);

      await closeHive(tester);
    },
  );

  testWidgets(
    'new Google sign-up after onboarding ends on Home with no second '
    'onboarding',
    (tester) async {
      await tester.runAsync(OnboardingPrefs.markSeen);
      final visitedRoutes = <String>[];
      await tester.pumpWidget(
        buildApp(
          const AuthAuthenticated(user, isNewUser: true),
          visitedRoutes: visitedRoutes,
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(find.text("I'm 18 or older"));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      await letHiveIoComplete(tester);

      expect(visitedRoutes, [AppRoutes.home]);
      expect(Hive.box<bool>('onboarding').get('seen_$uid'), isTrue);

      await closeHive(tester);
    },
  );
}
