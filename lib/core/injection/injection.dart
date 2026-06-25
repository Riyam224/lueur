import 'package:ai_therapist_app/core/cubits/theme_cubit.dart';
import 'package:ai_therapist_app/core/networking/dio_helper.dart';
import 'package:ai_therapist_app/features/plant/data/repositories/streak_repository.dart';
import 'package:ai_therapist_app/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/home/data/datasources/mood_local_datasource.dart';
import '../../features/home/data/datasources/mood_remote_datasource.dart';
import '../../features/home/data/repositories/mood_repository_impl.dart';
import '../../features/home/domain/repositories/mood_repository.dart';
import '../../features/home/presentation/cubit/mood_cubit.dart';
import '../../features/home/presentation/cubit/weekly_letter_cubit.dart';
import '../../features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import '../../features/quotes/data/repositories/saved_quotes_repository_impl.dart';
import '../../features/quotes/domain/repositories/saved_quotes_repository.dart';
import '../../features/quotes/domain/usecases/delete_quote_usecase.dart';
import '../../features/quotes/domain/usecases/get_saved_quotes_usecase.dart';
import '../../features/quotes/domain/usecases/save_quote_usecase.dart';
import '../../features/quotes/presentation/cubit/saved_quotes_cubit.dart';

final sl = GetIt.instance;

void setupInjection() {
  // ── Theme ──
  sl.registerLazySingleton(() => ThemeCubit());

  // ── Dio ──
  sl.registerLazySingleton(() => DioHelper());

  // ── Auth Repository ──
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // ── Auth UseCases ──
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ── Auth Cubit — factory always ──
  sl.registerFactory(() => AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        authRepository: sl(),
        moodCubit: sl(),
      ));

  // ── Mood DataSources ──
  sl.registerLazySingleton<MoodRemoteDatasource>(
    () => MoodRemoteDatasource(sl<DioHelper>().dio!),
  );
  sl.registerLazySingleton<MoodLocalDatasource>(() => MoodLocalDatasource());

  // ── Saved Quotes DataSource ──
  sl.registerLazySingleton<SavedQuotesLocalDatasource>(
    () => SavedQuotesLocalDatasource(),
  );

  // ── Mood Repository ──
  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepositoryImpl(sl(), sl()),
  );

  // ── Saved Quotes Repository ──
  sl.registerLazySingleton<SavedQuotesRepository>(
    () => SavedQuotesRepositoryImpl(sl()),
  );

  // ── Mood Cubit — singleton so all screens share state ──
  sl.registerLazySingleton(() => MoodCubit(sl()));

  // ── Saved Quotes UseCases ──
  sl.registerLazySingleton(() => GetSavedQuotesUseCase(sl()));
  sl.registerLazySingleton(() => SaveQuoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuoteUseCase(sl()));

  // ── Weekly Letter Cubit — factory ──
  sl.registerFactory<WeeklyLetterCubit>(
    () => WeeklyLetterCubit(sl<MoodRemoteDatasource>()),
  );

  // ── Saved Quotes Cubit — factory ──
  sl.registerFactory<SavedQuotesCubit>(
    () => SavedQuotesCubit(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepository(sl<DioHelper>().dio!),
  );

  sl.registerFactory<PlantCubit>(
    () => PlantCubit(sl<StreakRepository>()),
  );

  // ── Chat DataSource ──
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl<DioHelper>().dio!),
  );

  // ── Chat Repository ──
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Chat Cubit — factory; userId + initialMessages passed via GoRouter extra ──
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(repository: sl(), userId: ''),
  );
}
