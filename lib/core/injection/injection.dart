import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lueur/core/networking/auth_token_interceptor.dart';
import 'package:lueur/core/networking/dio_helper.dart';
import 'package:lueur/features/auth/data/datasources/auth_django_datasource.dart';
import 'package:lueur/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:lueur/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';
import 'package:lueur/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/login_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/register_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/sync_preferred_language_usecase.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:lueur/features/breathing/data/datasources/breathing_local_datasource.dart';
import 'package:lueur/features/breathing/data/repositories/breathing_repository_impl.dart';
import 'package:lueur/features/breathing/domain/repositories/breathing_repository.dart';
import 'package:lueur/features/breathing/domain/usecases/get_breathing_config_usecase.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_cubit.dart';
import 'package:lueur/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lueur/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur/features/draw/data/datasources/saved_drawings_local_datasource.dart';
import 'package:lueur/features/draw/data/repositories/saved_drawings_repository_impl.dart';
import 'package:lueur/features/draw/domain/repositories/saved_drawings_repository.dart';
import 'package:lueur/features/draw/domain/usecases/delete_drawing_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/get_saved_drawings_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/save_drawing_usecase.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/home/data/datasources/mood_remote_datasource.dart';
import 'package:lueur/features/home/data/repositories/mood_repository_impl.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/domain/usecases/log_activity_usecase.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:lueur/features/journal/domain/usecases/delete_journal_entry_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/get_journal_entries_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/set_journal_card_color_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/toggle_journal_pin_usecase.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/language/data/datasources/language_local_datasource.dart';
import 'package:lueur/features/language/data/repositories/language_repository_impl.dart';
import 'package:lueur/features/language/domain/repositories/language_repository.dart';
import 'package:lueur/features/language/domain/usecases/get_language_preference_usecase.dart';
import 'package:lueur/features/language/domain/usecases/set_language_preference_usecase.dart';
import 'package:lueur/features/language/presentation/cubit/language_cubit.dart';
import 'package:lueur/features/plant/domain/usecases/calculate_streak_usecase.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import 'package:lueur/features/quotes/data/repositories/saved_quotes_repository_impl.dart';
import 'package:lueur/features/quotes/domain/repositories/saved_quotes_repository.dart';
import 'package:lueur/features/quotes/domain/usecases/delete_quote_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/get_saved_quotes_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/save_quote_usecase.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/sudoku/data/datasources/sudoku_results_local_datasource.dart';
import 'package:lueur/features/sudoku/data/repositories/sudoku_results_repository_impl.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';
import 'package:lueur/features/sudoku/domain/usecases/delete_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/generate_sudoku_puzzle_async_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/get_sudoku_results_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/save_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/validate_sudoku_move_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_cubit.dart';
import 'package:lueur/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:lueur/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:lueur/features/theme/domain/repositories/theme_repository.dart';
import 'package:lueur/features/theme/domain/usecases/get_theme_mode_usecase.dart';
import 'package:lueur/features/theme/domain/usecases/set_theme_mode_usecase.dart';
import 'package:lueur/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

void setupInjection({required SharedPreferences sharedPreferences}) {
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton(
    () => ThemeLocalDatasource(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetThemeModeUseCase(sl()));
  sl.registerLazySingleton(() => SetThemeModeUseCase(sl()));
  sl.registerLazySingleton(
    () => ThemeCubit(
      getThemeModeUseCase: sl(),
      setThemeModeUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => LanguageLocalDatasource(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<LanguageRepository>(
    () => LanguageRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetLanguagePreferenceUseCase(sl()));
  sl.registerLazySingleton(() => SetLanguagePreferenceUseCase(sl()));
  sl.registerLazySingleton(
    () => LanguageCubit(
      getLanguagePreferenceUseCase: sl(),
      setLanguagePreferenceUseCase: sl(),
      syncPreferredLanguageUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(GoogleSignIn.new);

  sl.registerLazySingleton(() => AuthTokenInterceptor(sl()));
  sl.registerLazySingleton(() => DioHelper(sl()));

  sl.registerLazySingleton(
    () => AuthFirebaseDataSource(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton(() => AuthDjangoDatasource(sl<DioHelper>().dio));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => CheckSessionUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SyncPreferredLanguageUseCase(sl()));

  // singleton — shared across all routes
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      checkSessionUseCase: sl(),
      onSessionCleared: () async {
        await sl<MoodLocalDatasource>().clearGuestHistory();
        sl<MoodCubit>().clearEntries();
      },
    ),
  );

  // factory — scoped to its own screen
  sl.registerFactory(() => ForgotPasswordCubit(sl()));

  sl.registerLazySingleton<MoodRemoteDatasource>(
    () => MoodRemoteDatasource(sl<DioHelper>().dio),
  );
  sl.registerLazySingleton<MoodLocalDatasource>(MoodLocalDatasource.new);

  sl.registerLazySingleton<SavedQuotesLocalDatasource>(
    SavedQuotesLocalDatasource.new,
  );

  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => LogActivityUseCase(sl()));

  sl.registerLazySingleton<SavedQuotesRepository>(
    () => SavedQuotesRepositoryImpl(sl(), sl()),
  );

  // singleton — shared across all shell tabs
  sl.registerLazySingleton(() => MoodCubit(sl()));

  sl.registerLazySingleton(() => GetSavedQuotesUseCase(sl()));
  sl.registerLazySingleton(() => SaveQuoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuoteUseCase(sl()));

  sl.registerFactory<WeeklyLetterCubit>(
    () => WeeklyLetterCubit(sl<MoodRemoteDatasource>()),
  );

  sl.registerFactory<SavedQuotesCubit>(
    () => SavedQuotesCubit(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<CalculateStreakUseCase>(
    () => CalculateStreakUseCase(sl<MoodRepository>()),
  );
  sl.registerFactory<PlantCubit>(
    () => PlantCubit(sl<CalculateStreakUseCase>()),
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl<DioHelper>().dio),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(BreathingLocalDatasource.new);
  sl.registerLazySingleton<BreathingRepository>(
    () => BreathingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetBreathingConfigUseCase(sl()));
  sl.registerFactory<BreathingCubit>(
    () => BreathingCubit(sl(), sl()),
  );

  // presentation-only, ephemeral, no persistence
  sl.registerFactory<DrawCubit>(DrawCubit.new);

  // reuses MoodRepository, its own use case layer
  sl.registerLazySingleton(() => GetJournalEntriesUseCase(sl()));
  sl.registerLazySingleton(() => SetJournalCardColorUseCase(sl()));
  sl.registerLazySingleton(() => ToggleJournalPinUseCase(sl()));
  sl.registerLazySingleton(() => DeleteJournalEntryUseCase(sl()));
  sl.registerFactory<JournalGridCubit>(
    () => JournalGridCubit(
      getEntriesUseCase: sl(),
      setCardColorUseCase: sl(),
      togglePinUseCase: sl(),
      deleteEntryUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<SudokuResultsLocalDatasource>(
    SudokuResultsLocalDatasource.new,
  );
  sl.registerLazySingleton<SudokuResultsRepository>(
    () => SudokuResultsRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetSudokuResultsUseCase(sl()));
  sl.registerLazySingleton(() => SaveSudokuResultUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSudokuResultUseCase(sl()));
  sl.registerLazySingleton(GenerateSudokuPuzzleAsyncUseCase.new);
  sl.registerLazySingleton(ValidateSudokuMoveUseCase.new);
  sl.registerFactory<SudokuCubit>(
    () => SudokuCubit(sl<GenerateSudokuPuzzleAsyncUseCase>(), sl(), sl(), sl()),
  );
  sl.registerFactory<SudokuResultsCubit>(
    () => SudokuResultsCubit(sl(), sl()),
  );

  sl.registerLazySingleton<SavedDrawingsLocalDatasource>(
    SavedDrawingsLocalDatasource.new,
  );
  sl.registerLazySingleton<SavedDrawingsRepository>(
    () => SavedDrawingsRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetSavedDrawingsUseCase(sl()));
  sl.registerLazySingleton(() => SaveDrawingUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDrawingUseCase(sl()));
  sl.registerFactory<SavedDrawingsCubit>(
    () => SavedDrawingsCubit(sl(), sl(), sl()),
  );
}
