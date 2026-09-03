import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
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
import 'package:lueur/features/profile/presentation/widgets/profile_account_section_widget.dart';
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
  Future<Either<Failure, void>> logout() =>
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
  Widget buildApp(AuthCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const ProfileAccountSectionWidget(),
          ),
        ),
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

  testWidgets('tapping the tile shows the delete-account confirmation dialog',
      (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await tester.pumpWidget(buildApp(cubit));

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete your account permanently?'), findsOneWidget);
  });

  testWidgets('canceling the confirmation does not delete the account',
      (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await tester.pumpWidget(buildApp(cubit));

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repo.deleteAccountCalled, isFalse);
  });

  testWidgets('confirming deletes the account', (tester) async {
    final repo = _FakeAuthRepository();
    final cubit = buildCubit(repo);
    await tester.pumpWidget(buildApp(cubit));

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    // Disambiguate from the underlying ListTile's "Delete account" label,
    // which stays in the tree behind the dialog overlay.
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete account'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.deleteAccountCalled, isTrue);
  });

  testWidgets(
    'the confirmation dialog is distinct from the delete-all-entries dialog',
    (tester) async {
      final repo = _FakeAuthRepository();
      final cubit = buildCubit(repo);
      await tester.pumpWidget(buildApp(cubit));

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      // Own title and message, not the journal "delete all entries" copy —
      // and unmistakably calls out permanence and account-wide scope.
      expect(find.text('Delete your account permanently?'), findsOneWidget);
      expect(find.text('Delete all entries?'), findsNothing);
      expect(
        find.textContaining('permanently deletes your account'),
        findsOneWidget,
      );
      expect(
        find.text(
          'This will permanently remove all journal entries from your device.',
        ),
        findsNothing,
      );
    },
  );
}
