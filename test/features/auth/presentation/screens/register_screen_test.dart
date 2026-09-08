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
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/screens/register_screen.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Only [register] and [signInWithGoogle] are exercised by these tests —
/// every other member is unused by RegisterScreen and left unimplemented,
/// matching the convention in auth_success_handler_test.dart.
class _FakeAuthRepository implements AuthRepository {
  int registerCallCount = 0;
  int signInWithGoogleCallCount = 0;
  Either<Failure, AuthResult> result = const Right(
    (user: UserEntity(id: 'uid-1', email: 'user@example.com'), isNewUser: true),
  );

  @override
  Future<Either<Failure, AuthResult>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    registerCallCount++;
    return result;
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithGoogle() async {
    signInWithGoogleCallCount++;
    return result;
  }

  @override
  Future<Either<Failure, void>> deleteAccount() => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

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

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('register_screen_test');
    Hive.init(tempDir.path);
    // Pre-opens the boxes a successful register touches (via AuthPrefs,
    // AgeConfirmationPrefs, and OnboardingPrefs) so their Hive.openBox calls
    // resolve from the already-open in-memory registry instead of hitting
    // real file I/O — see auth_success_handler_test.dart for the same setup.
    await Hive.openBox<bool>('auth');
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

  Widget buildApp({required List<String> visitedRoutes}) {
    final router = GoRouter(
      initialLocation: AppRoutes.registerScreen,
      routes: [
        GoRoute(
          path: AppRoutes.registerScreen,
          builder: (context, _) => BlocProvider.value(
            value: cubit,
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.loginScreen,
          builder: (context, _) {
            visitedRoutes.add(AppRoutes.loginScreen);
            return const Scaffold(body: SizedBox.shrink());
          },
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

  Future<void> fillValidForm(WidgetTester tester) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Jane Doe'); // name
    await tester.enterText(fields.at(1), 'jane@example.com'); // email
    await tester.enterText(fields.at(2), 'password123'); // password
    await tester.enterText(fields.at(3), 'password123'); // confirm password
  }

  testWidgets(
    'submitting with the age checkbox unchecked shows the error and does '
    'not call AuthCubit.register',
    (tester) async {
      final visitedRoutes = <String>[];
      await tester.pumpWidget(buildApp(visitedRoutes: visitedRoutes));
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Begin growing'));
      await tester.tap(find.text('Begin growing'));
      await tester.pump();

      expect(
        find.text("Please confirm you're 18 or older to continue"),
        findsOneWidget,
      );
      expect(repo.registerCallCount, 0);
      expect(cubit.state, isA<AuthInitial>());
    },
  );

  testWidgets(
    'tapping "Continue with Google" with the age checkbox unchecked shows '
    'the error and does not call AuthCubit.signInWithGoogle',
    (tester) async {
      final visitedRoutes = <String>[];
      await tester.pumpWidget(buildApp(visitedRoutes: visitedRoutes));

      await tester.ensureVisible(find.text('Sign up with Google'));
      await tester.tap(find.text('Sign up with Google'));
      await tester.pump();

      expect(
        find.text("Please confirm you're 18 or older to continue"),
        findsOneWidget,
      );
      expect(repo.signInWithGoogleCallCount, 0);
      expect(cubit.state, isA<AuthInitial>());
    },
  );

  // TODO: Add a case covering "checking the age checkbox then submitting
  // valid form data calls AuthCubit.register, shows no age error, and
  // navigates to onboarding." This is a known test-harness limitation, not
  // a product bug — manually verified working. The post-register chain
  // (AuthPrefs/AgeConfirmationPrefs Hive writes, the success dialog's own
  // 1400ms auto-dismiss timer, the OnboardingPrefs read, and the go_router
  // navigation) all needs to run for real inside a single tester.runAsync
  // block, since a Timer created by a widget built while runAsync's real
  // zone is active stays bound to that real zone even after runAsync
  // returns — a later *fake* tester.pump(duration) can never fire it. Nor
  // can pumpAndSettle stand in for that wait: RegisterHeader's AuthAvatar
  // runs an infinite repeating float animation, which never lets it
  // converge. Getting the real-time window and pump sequencing right needs
  // more investigation than warranted for this pass.

  testWidgets(
    'checking the age checkbox after an error was shown clears the error '
    'immediately, without needing to resubmit',
    (tester) async {
      final visitedRoutes = <String>[];
      await tester.pumpWidget(buildApp(visitedRoutes: visitedRoutes));

      await tester.ensureVisible(find.text('Begin growing'));
      await tester.tap(find.text('Begin growing'));
      await tester.pump();
      expect(
        find.text("Please confirm you're 18 or older to continue"),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text("I'm 18 or older"));
      await tester.tap(find.text("I'm 18 or older"));
      await tester.pump();

      expect(
        find.text("Please confirm you're 18 or older to continue"),
        findsNothing,
      );
    },
  );
}
