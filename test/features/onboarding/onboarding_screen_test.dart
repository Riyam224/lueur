import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/injection/injection.dart';
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
import 'package:lueur/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:lueur/features/onboarding/presentation/widgets/onboarding_skip_button.dart';
import 'package:lueur/l10n/app_localizations.dart';

class _FakeAuthRepository implements AuthRepository {
  UserEntity? sessionUser;

  @override
  Future<Either<Failure, UserEntity?>> checkSession() async =>
      Right(sessionUser);

  @override
  Future<Either<Failure, void>> deleteAccount() => throw UnimplementedError();

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
  late Box<bool> onboardingBox;
  late Box<bool> authBox;

  const uid = 'uid-1';
  const user = UserEntity(id: uid, email: 'user@example.com');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('onboarding_screen_test');
    Hive.init(tempDir.path);
    // Pre-opened so the screen's Hive.openBox calls resolve from the
    // in-memory registry — real file I/O never resolves under pump().
    onboardingBox = await Hive.openBox<bool>('onboarding');
    authBox = await Hive.openBox<bool>('auth');

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
    sl.registerSingleton<AuthCubit>(cubit);
  });

  tearDown(() async {
    await sl.reset();
    await cubit.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  Future<List<String>> finishOnboarding(
    WidgetTester tester, {
    bool hasEverAuthenticated = false,
  }) async {
    if (hasEverAuthenticated) {
      await tester.runAsync(() => authBox.put('hasEverAuthenticated', true));
    }
    // Phone-sized surface — the onboarding card overflows the default 800x600.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final visited = <String>[];
    GoRoute stub(String path) => GoRoute(
          path: path,
          builder: (context, _) {
            visited.add(path);
            return const Scaffold(body: SizedBox.shrink());
          },
        );

    final router = GoRouter(
      initialLocation: AppRoutes.onBoarding,
      routes: [
        GoRoute(
          path: AppRoutes.onBoarding,
          builder: (context, _) => const OnboardingScreen(),
        ),
        stub(AppRoutes.home),
        stub(AppRoutes.loginScreen),
        stub(AppRoutes.registerScreen),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(OnboardingSkipButton));
    // The tap's Hive writes are made inside the fake-async zone: their file
    // I/O only completes in real time, and their continuations only run when
    // the fake zone is pumped — so alternate the two.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    return visited;
  }

  // Hive's internal write-lock futures were created in the fake-async zone
  // by the tap, so closing the box needs fake-zone pumps too — without this,
  // tearDown's Hive.deleteFromDisk() waits forever once the body has ended.
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

  testWidgets(
    'finishing while authenticated goes Home and records seen_<uid>',
    (tester) async {
      repo.sessionUser = user;
      await cubit.checkSession();

      expect(await finishOnboarding(tester), [AppRoutes.home]);
      expect(onboardingBox.get('seen_$uid'), isTrue);
      expect(onboardingBox.containsKey('pending'), isFalse);

      await closeHive(tester);
    },
  );

  testWidgets(
    'fresh install: finishing while signed out goes to Register and leaves '
    'completion pending',
    (tester) async {
      expect(await finishOnboarding(tester), [AppRoutes.registerScreen]);
      expect(onboardingBox.get('pending'), isTrue);

      await closeHive(tester);
    },
  );

  testWidgets(
    'device that has authenticated before: finishing while signed out goes '
    'to Login and leaves completion pending',
    (tester) async {
      expect(
        await finishOnboarding(tester, hasEverAuthenticated: true),
        [AppRoutes.loginScreen],
      );
      expect(onboardingBox.get('pending'), isTrue);

      await closeHive(tester);
    },
  );
}
