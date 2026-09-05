import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:lueur/features/profile/presentation/widgets/profile_auth_action_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

class _FakeAuthRepository implements AuthRepository {
  bool logoutCalled = false;

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() =>
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
  Widget buildApp(AuthCubit cubit, {required List<String> visitedRoutes}) {
    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: const ProfileAuthActionWidget(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.loginScreen,
          builder: (context, state) {
            visitedRoutes.add(AppRoutes.loginScreen);
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
        GoRoute(
          path: AppRoutes.registerScreen,
          builder: (context, state) {
            visitedRoutes.add(AppRoutes.registerScreen);
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

  AuthCubit buildCubit(_FakeAuthRepository repo) => AuthCubit(
        loginUseCase: LoginUseCase(repo),
        registerUseCase: RegisterUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
        signInWithGoogleUseCase: SignInWithGoogleUseCase(repo),
        checkSessionUseCase: CheckSessionUseCase(repo),
        deleteAccountUseCase: DeleteAccountUseCase(repo),
        onSessionCleared: () async {},
        onAccountDeleted: (_) async {},
      );

  testWidgets('shows Log out for a signed-in (non-guest) session',
      (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await tester.pumpWidget(buildApp(cubit, visitedRoutes: []));

    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
    expect(find.text('Register'), findsNothing);
  });

  testWidgets('shows Log in / Register instead of Log out for a guest session',
      (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await cubit.enterGuestMode();
    await tester.pumpWidget(buildApp(cubit, visitedRoutes: []));

    expect(find.text('Log out'), findsNothing);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('tapping Log in as a guest navigates to the login screen',
      (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await cubit.enterGuestMode();
    final visitedRoutes = <String>[];
    await tester.pumpWidget(buildApp(cubit, visitedRoutes: visitedRoutes));

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, [AppRoutes.loginScreen]);
  });

  testWidgets('tapping Register as a guest navigates to the register screen',
      (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await cubit.enterGuestMode();
    final visitedRoutes = <String>[];
    await tester.pumpWidget(buildApp(cubit, visitedRoutes: visitedRoutes));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, [AppRoutes.registerScreen]);
  });

  testWidgets('tapping Log out as a signed-in user calls repository logout',
      (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await tester.pumpWidget(buildApp(cubit, visitedRoutes: []));

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(repo.logoutCalled, isTrue);
  });
}
