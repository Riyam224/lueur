import 'package:ai_therapist_app/core/cubits/theme_cubit.dart';
import 'package:ai_therapist_app/core/networking/auth_token_interceptor.dart';
import 'package:ai_therapist_app/core/networking/dio_helper.dart';
import 'package:ai_therapist_app/features/auth/data/datasources/auth_django_datasource.dart';
import 'package:ai_therapist_app/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:ai_therapist_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ai_therapist_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_therapist_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:ai_therapist_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ai_therapist_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:ai_therapist_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:ai_therapist_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ai_therapist_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:ai_therapist_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:ai_therapist_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ai_therapist_app/features/home/data/datasources/mood_local_datasource.dart';
import 'package:ai_therapist_app/features/home/data/datasources/mood_remote_datasource.dart';
import 'package:ai_therapist_app/features/home/data/repositories/mood_repository_impl.dart';
import 'package:ai_therapist_app/features/home/domain/repositories/mood_repository.dart';
import 'package:ai_therapist_app/features/home/presentation/cubit/mood_cubit.dart';
import 'package:ai_therapist_app/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:ai_therapist_app/features/plant/data/repositories/streak_repository.dart';
import 'package:ai_therapist_app/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:ai_therapist_app/features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import 'package:ai_therapist_app/features/quotes/data/repositories/saved_quotes_repository_impl.dart';
import 'package:ai_therapist_app/features/quotes/domain/repositories/saved_quotes_repository.dart';
import 'package:ai_therapist_app/features/quotes/domain/usecases/delete_quote_usecase.dart';
import 'package:ai_therapist_app/features/quotes/domain/usecases/get_saved_quotes_usecase.dart';
import 'package:ai_therapist_app/features/quotes/domain/usecases/save_quote_usecase.dart';
import 'package:ai_therapist_app/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // ── Auth Cubit — singleton shared across all routes ────────────────────────
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      signInWithGoogleUseCase: sl(),
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
}
