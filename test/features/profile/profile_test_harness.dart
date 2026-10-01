import 'dart:async';

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
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/domain/repositories/saved_drawings_repository.dart';
import 'package:lueur/features/draw/domain/usecases/delete_drawing_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/get_saved_drawings_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/save_drawing_usecase.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
import 'package:lueur/features/draw/presentation/screens/saved_drawing_viewer_screen.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/presentation/cubit/language_cubit.dart';
import 'package:lueur/features/profile/presentation/screens/profile_screen.dart';
import 'package:lueur/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:lueur/features/quotes/domain/repositories/saved_quotes_repository.dart';
import 'package:lueur/features/quotes/domain/usecases/delete_quote_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/get_saved_quotes_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/save_quote_usecase.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/screens/saved_quotes_screen.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';
import 'package:lueur/features/sudoku/domain/usecases/delete_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/get_sudoku_results_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_cubit.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Shared in-memory fakes for Profile tests — no Hive, no network.
class FakeDrawingsRepository implements SavedDrawingsRepository {
  Either<Failure, List<SavedDrawingEntity>> next = const Right([]);
  final deletedIds = <String>[];

  @override
  Future<Either<Failure, List<SavedDrawingEntity>>> getDrawings() async => next;

  @override
  Future<Either<Failure, SavedDrawingEntity>> saveDrawing(
    List<SavedDrawingPathEntity> paths,
  ) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteDrawing(String id) async {
    deletedIds.add(id);
    next = next.map((list) => list.where((d) => d.id != id).toList());
    return const Right(null);
  }
}

class FakeSudokuRepository implements SudokuResultsRepository {
  Either<Failure, List<SudokuResultEntity>> next = const Right([]);
  final deletedIds = <String>[];

  @override
  Future<Either<Failure, List<SudokuResultEntity>>> getResults() async => next;

  @override
  Future<Either<Failure, SudokuResultEntity>> saveResult({
    required bool won,
    required int mistakes,
    required int durationSeconds,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteResult(String id) async {
    deletedIds.add(id);
    next = next.map((list) => list.where((r) => r.id != id).toList());
    return const Right(null);
  }
}

class FakeQuotesRepository implements SavedQuotesRepository {
  Either<Failure, List<SavedQuoteEntity>> next = const Right([]);

  @override
  Future<Either<Failure, List<SavedQuoteEntity>>> getQuotes() async => next;

  @override
  Future<Either<Failure, SavedQuoteEntity>> saveQuote(
    String text, {
    String? emoji,
    String? thoughts,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteQuote(String id) =>
      throw UnimplementedError();
}

class FakeAuthRepository implements AuthRepository {
  UserEntity? sessionUser;

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
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, AuthResult>> signInWithGoogle() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity?>> checkSession() async =>
      Right(sessionUser);

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> syncPreferredLanguage(String languageCode) =>
      throw UnimplementedError();
}

class FakeThemeCubit extends Cubit<ThemeModeOption> implements ThemeCubit {
  FakeThemeCubit() : super(ThemeModeOption.system);

  @override
  Future<void> setThemeMode(ThemeModeOption mode) async => emit(mode);
}

class FakeLanguageCubit extends Cubit<Locale> implements LanguageCubit {
  FakeLanguageCubit(super.initial);

  @override
  Future<bool> changeLanguage(AppLanguage language) async => true;
}

AuthCubit buildAuthCubit([FakeAuthRepository? repository]) {
  final repo = repository ?? FakeAuthRepository();
  return AuthCubit(
    loginUseCase: LoginUseCase(repo),
    registerUseCase: RegisterUseCase(repo),
    logoutUseCase: LogoutUseCase(repo),
    signInWithGoogleUseCase: SignInWithGoogleUseCase(repo),
    checkSessionUseCase: CheckSessionUseCase(repo),
    deleteAccountUseCase: DeleteAccountUseCase(repo),
    onSessionCleared: () async {},
    onAccountDeleted: (_) async {},
  );
}

/// The Profile tab's real cubits over in-memory fakes.
class ProfileHarness {
  final drawingsRepo = FakeDrawingsRepository();
  final sudokuRepo = FakeSudokuRepository();
  final quotesRepo = FakeQuotesRepository();
  final authRepo = FakeAuthRepository();

  late final drawings = SavedDrawingsCubit(
    GetSavedDrawingsUseCase(drawingsRepo),
    SaveDrawingUseCase(drawingsRepo),
    DeleteDrawingUseCase(drawingsRepo),
  );
  late final sudoku = SudokuResultsCubit(
    GetSudokuResultsUseCase(sudokuRepo),
    DeleteSudokuResultUseCase(sudokuRepo),
  );
  late final quotes = SavedQuotesCubit(
    GetSavedQuotesUseCase(quotesRepo),
    SaveQuoteUseCase(quotesRepo),
    DeleteQuoteUseCase(quotesRepo),
  );
  late final auth = buildAuthCubit(authRepo);

  Future<void> close() async {
    await drawings.close();
    await sudoku.close();
    await quotes.close();
    await auth.close();
  }

  /// Wraps [child] with every provider the Profile tab reads.
  Widget providers(Widget child, {Locale locale = const Locale('en')}) =>
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: auth),
          BlocProvider.value(value: drawings),
          BlocProvider.value(value: sudoku),
          BlocProvider.value(value: quotes),
          BlocProvider<ThemeCubit>(create: (_) => FakeThemeCubit()),
          BlocProvider<LanguageCubit>(create: (_) => FakeLanguageCubit(locale)),
        ],
        child: child,
      );

  /// Builds a router with /profile (the real screen) and a plain /other
  /// route to push on top of it.
  GoRouter router() => GoRouter(
        initialLocation: AppRoutes.profile,
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, _) =>
                providers(const Scaffold(body: ProfileScreen())),
          ),
          GoRoute(
            path: '/other',
            builder: (context, _) => const Scaffold(body: Text('other')),
          ),
          GoRoute(
            path: AppRoutes.savedQuotes,
            builder: (context, _) => BlocProvider(
              create: (_) {
                final cubit = SavedQuotesCubit(
                  GetSavedQuotesUseCase(quotesRepo),
                  SaveQuoteUseCase(quotesRepo),
                  DeleteQuoteUseCase(quotesRepo),
                );
                unawaited(cubit.loadQuotes());
                return cubit;
              },
              child: const SavedQuotesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.savedDrawingViewer,
            builder: (context, state) {
              final extra = state.extra! as Map<String, dynamic>;
              return SavedDrawingViewerScreen(
                drawing: extra['drawing'] as SavedDrawingEntity,
                onDelete: extra['onDelete'] as VoidCallback,
              );
            },
          ),
        ],
      );
}

Widget testApp({
  GoRouter? router,
  Widget? home,
  Locale locale = const Locale('en'),
}) =>
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => router != null
          ? MaterialApp.router(
              theme: AppTheme.light,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            )
          : MaterialApp(
              theme: AppTheme.light,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: home,
            ),
    );

/// Phone-sized surface so Profile's sections lay out like on a device.
void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}
