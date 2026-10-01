import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/errors/failures.dart';
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
import 'package:lueur/features/splash/presentation/constants/splash_constants.dart';
import 'package:lueur/features/splash/presentation/screens/splash_screen.dart';
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
    tempDir = await Directory.systemTemp.createTemp('splash_screen_test');
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
  });

  tearDown(() async {
    await cubit.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  // Seeding writes hit real file I/O, which only completes outside the
  // testWidgets fake-async zone.
  Future<void> seed(
    WidgetTester tester, {
    Map<String, bool> onboarding = const {},
    bool hasEverAuthenticated = false,
  }) =>
      tester.runAsync(() async {
        await onboardingBox.putAll(onboarding);
        if (hasEverAuthenticated) {
          await authBox.put('hasEverAuthenticated', true);
        }
      });

  Future<List<String>> launch(WidgetTester tester) async {
    final visited = <String>[];
    GoRoute stub(String path) => GoRoute(
          path: path,
          builder: (context, _) {
            visited.add(path);
            return const Scaffold(body: SizedBox.shrink());
          },
        );

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, _) => BlocProvider.value(
            value: cubit,
            child: const SplashScreen(),
          ),
        ),
        stub(AppRoutes.home),
        stub(AppRoutes.onBoarding),
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
    await tester.pump(SplashConstants.navigationDelay);
    await tester.pumpAndSettle();
    return visited;
  }

  testWidgets('new account relaunch with a valid session goes to Home',
      (tester) async {
    // State right after register: pending already converted to seen_<uid>.
    await seed(
      tester,
      onboarding: {'seen_$uid': true},
      hasEverAuthenticated: true,
    );
    repo.sessionUser = user;

    expect(await launch(tester), [AppRoutes.home]);
  });

  testWidgets('a valid session goes to Home even with no onboarding flags',
      (tester) async {
    repo.sessionUser = user;

    expect(await launch(tester), [AppRoutes.home]);
  });

  testWidgets('logged-out returning user goes to Login', (tester) async {
    await seed(
      tester,
      onboarding: {'seen_$uid': true},
      hasEverAuthenticated: true,
    );

    expect(await launch(tester), [AppRoutes.loginScreen]);
  });

  testWidgets('first install shows Onboarding', (tester) async {
    expect(await launch(tester), [AppRoutes.onBoarding]);
  });

  testWidgets('guest relaunch (pending only, never authenticated) goes to '
      'Register', (tester) async {
    await seed(tester, onboarding: {'pending': true});

    expect(await launch(tester), [AppRoutes.registerScreen]);
  });

  testWidgets('existing user with only seen_<uid> and a session goes to Home',
      (tester) async {
    await seed(tester, onboarding: {'seen_$uid': true});
    repo.sessionUser = user;

    expect(await launch(tester), [AppRoutes.home]);
  });
}
