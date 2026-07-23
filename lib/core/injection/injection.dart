import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lueur/core/cubits/theme_cubit.dart';
import 'package:lueur/core/networking/auth_token_interceptor.dart';
import 'package:lueur/core/networking/dio_helper.dart';
import 'package:lueur/features/auth/data/datasources/auth_django_datasource.dart';
import 'package:lueur/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:lueur/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';
import 'package:lueur/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/login_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/register_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/breathing/data/datasources/breathing_local_datasource.dart';
import 'package:lueur/features/breathing/data/repositories/breathing_repository_impl.dart';
import 'package:lueur/features/breathing/domain/repositories/breathing_repository.dart';
import 'package:lueur/features/breathing/domain/usecases/get_breathing_config_usecase.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_cubit.dart';
import 'package:lueur/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lueur/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/home/data/datasources/mood_remote_datasource.dart';
import 'package:lueur/features/home/data/repositories/mood_repository_impl.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:lueur/features/plant/data/repositories/streak_repository.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import 'package:lueur/features/quotes/data/repositories/saved_quotes_repository_impl.dart';
import 'package:lueur/features/quotes/domain/repositories/saved_quotes_repository.dart';
import 'package:lueur/features/quotes/domain/usecases/delete_quote_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/get_saved_quotes_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/save_quote_usecase.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';

final sl = GetIt.instance;

void setupInjection() {
  // ── Theme ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(ThemeCubit.new);

  // ── Firebase ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(GoogleSignIn.new);

  // ── Networking ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => AuthTokenInterceptor(sl()));
  sl.registerLazySingleton(() => DioHelper(sl()));

  // ── Auth DataSources ───────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => AuthFirebaseDataSource(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton(() => AuthDjangoDatasource(sl<DioHelper>().dio));

  // ── Auth Repository ────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // ── Auth UseCases ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => CheckSessionUseCase(sl()));

  // ── Auth Cubit — singleton shared across all routes ────────────────────────
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      checkSessionUseCase: sl(),
      onLogout: sl<MoodCubit>().clearEntries,
    ),
  );

  // ── Mood DataSources ───────────────────────────────────────────────────────
  sl.registerLazySingleton<MoodRemoteDatasource>(
    () => MoodRemoteDatasource(sl<DioHelper>().dio),
  );
  sl.registerLazySingleton<MoodLocalDatasource>(MoodLocalDatasource.new);

  // ── Saved Quotes DataSource ────────────────────────────────────────────────
  sl.registerLazySingleton<SavedQuotesLocalDatasource>(
    SavedQuotesLocalDatasource.new,
  );

  // ── Mood Repository ────────────────────────────────────────────────────────
  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepositoryImpl(sl(), sl(), sl()),
  );

  // ── Saved Quotes Repository ────────────────────────────────────────────────
  sl.registerLazySingleton<SavedQuotesRepository>(
    () => SavedQuotesRepositoryImpl(sl(), sl()),
  );

  // ── Mood Cubit — singleton shared across all shell tabs ───────────────────
  sl.registerLazySingleton(() => MoodCubit(sl()));

  // ── Saved Quotes UseCases ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetSavedQuotesUseCase(sl()));
  sl.registerLazySingleton(() => SaveQuoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuoteUseCase(sl()));

  // ── Weekly Letter Cubit — factory ─────────────────────────────────────────
  sl.registerFactory<WeeklyLetterCubit>(
    () => WeeklyLetterCubit(sl<MoodRemoteDatasource>()),
  );

  // ── Saved Quotes Cubit — factory ──────────────────────────────────────────
  sl.registerFactory<SavedQuotesCubit>(
    () => SavedQuotesCubit(sl(), sl(), sl()),
  );

  // ── Plant ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepository(sl<DioHelper>().dio, sl()),
  );
  sl.registerFactory<PlantCubit>(
    () => PlantCubit(sl<StreakRepository>()),
  );

  // ── Chat ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl<DioHelper>().dio),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Breathing ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(BreathingLocalDatasource.new);
  sl.registerLazySingleton<BreathingRepository>(
    () => BreathingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetBreathingConfigUseCase(sl()));
  sl.registerFactory<BreathingCubit>(
    () => BreathingCubit(sl()),
  );

  // ── Free Draw — presentation-only, ephemeral, no persistence ──────────────
  sl.registerFactory<DrawCubit>(DrawCubit.new);
}
