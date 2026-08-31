import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/models/mood_choice_destination.dart';
import 'package:lueur/core/navigation/main_shell_screen.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/features/affirmation/presentation/screens/affirmation_screen.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:lueur/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:lueur/features/auth/presentation/screens/login_screen.dart';
import 'package:lueur/features/auth/presentation/screens/register_screen.dart';
import 'package:lueur/features/breathing/presentation/screens/breathing_screen.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:lueur/features/chat/presentation/screens/chat_screen.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
import 'package:lueur/features/draw/presentation/screens/free_draw_screen.dart';
import 'package:lueur/features/draw/presentation/screens/saved_drawing_viewer_screen.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:lueur/features/home/presentation/screens/home_screen.dart';
import 'package:lueur/features/home/presentation/screens/weekly_letter_screen.dart';
import 'package:lueur/features/journal/presentation/screens/journal_grid_screen.dart';
import 'package:lueur/features/journal/presentation/screens/timeline_screen.dart';
import 'package:lueur/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:lueur/features/plant/presentation/screens/streak_celebration_screen.dart';
import 'package:lueur/features/profile/presentation/screens/profile_screen.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/screens/saved_quotes_screen.dart';
import 'package:lueur/features/response/presentation/screens/response_ai_screen.dart';
import 'package:lueur/features/splash/presentation/screens/splash_screen.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_cubit.dart';
import 'package:lueur/features/sudoku/presentation/screens/sudoku_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class RouterGenerationConfig {
  static CustomTransitionPage _buildTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static GoRouter goRouter = GoRouter(
    // todo intial screen  _____
    initialLocation: AppRoutes.splash,
    observers: [
      SentryNavigatorObserver(),
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    onException: (context, state, router) {
      router.go(AppRoutes.splash);
    },
    routes: [
      // Splash
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const SplashScreen(),
          ),
        ),
      ),

// onboarding
      // Auth
      GoRoute(
        name: AppRoutes.onBoarding,
        path: AppRoutes.onBoarding,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      // Auth
      GoRoute(
        name: AppRoutes.loginScreen,
        path: AppRoutes.loginScreen,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const LoginScreen(),
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.registerScreen,
        path: AppRoutes.registerScreen,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const RegisterScreen(),
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.forgotPasswordScreen,
        path: AppRoutes.forgotPasswordScreen,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<ForgotPasswordCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      ),

      // Main app shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final moodCubit = sl<MoodCubit>();
          if (moodCubit.state is MoodInitial) moodCubit.getHistory();
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: moodCubit),
              BlocProvider.value(value: sl<AuthCubit>()),
            ],
            child: BlocListener<AuthCubit, AuthState>(
              listenWhen: (previous, current) => current is AuthUnauthenticated,
              listener: (ctx, authState) {
                if (authState is AuthUnauthenticated) {
                  ctx.go(AppRoutes.loginScreen);
                }
              },
              child: MainShellScreen(navigationShell: navigationShell),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.home,
                path: AppRoutes.home,
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.journal,
                path: AppRoutes.journal,
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: const JournalGridScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.profile,
                path: AppRoutes.profile,
                pageBuilder: (context, state) => _buildTransitionPage(
                  state: state,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => sl<SavedQuotesCubit>()..loadQuotes(),
                      ),
                      BlocProvider(
                        create: (_) => sl<SavedDrawingsCubit>()..loadDrawings(),
                      ),
                      BlocProvider(
                        create: (_) => sl<SudokuResultsCubit>()..loadResults(),
                      ),
                    ],
                    child: const ProfileScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Response screen — standalone, provides its own MoodCubit
      GoRoute(
        name: AppRoutes.response,
        path: AppRoutes.response,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final emojiPath = extra?['emojiPath'] as String?;
          final emojiUnicode = extra?['emojiUnicode'] as String?;
          final thoughts = extra?['thoughts'] as String? ?? '';

          return _buildTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<MoodCubit>()),
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider(create: (_) => sl<SavedQuotesCubit>()),
              ],
              child: ResponseAiScreen(
                emojiImagePath: emojiPath,
                emojiUnicode: emojiUnicode,
                thoughts: thoughts,
              ),
            ),
          );
        },
      ),

      GoRoute(
        name: AppRoutes.chat,
        path: AppRoutes.chat,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final userId = extra?['userId'] as String? ?? '';
          final emoji = extra?['emoji'] as String? ?? '😊';
          final thoughts = extra?['thoughts'] as String? ?? '';
          final aiResponse = extra?['aiResponse'] as String? ?? '';
          // A full day's worth of messages (e.g. from the journal grid,
          // where one bubble can represent several check-ins that day)
          // takes priority over the single thoughts/aiResponse pair below.
          final rawHistory = extra?['history'] as List<dynamic>?;
          final dayHistory = rawHistory
              ?.map((e) => e as Map<String, dynamic>)
              .map(
                (e) => ChatMessage(
                  role: e['role'] as String,
                  content: e['content'] as String,
                ),
              )
              .toList();
          // Thoughts with no reply yet (e.g. from the post-exercise check-in)
          // are sent to Luna automatically instead of preloaded as history.
          final needsAutoSend =
              dayHistory == null && thoughts.isNotEmpty && aiResponse.isEmpty;
          return _buildTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => ChatCubit(
                    repository: sl<ChatRepository>(),
                    userId: userId,
                    initialMessages: dayHistory ??
                        (needsAutoSend
                            ? const []
                            : [
                                if (thoughts.isNotEmpty)
                                  ChatMessage(role: 'user', content: thoughts),
                                if (aiResponse.isNotEmpty)
                                  ChatMessage(
                                    role: 'assistant',
                                    content: aiResponse,
                                  ),
                              ]),
                  ),
                ),
                BlocProvider(create: (_) => sl<SavedQuotesCubit>()),
              ],
              child: ChatScreen(
                emoji: emoji,
                autoSendThoughts: needsAutoSend ? thoughts : null,
              ),
            ),
          );
        },
      ),

      GoRoute(
        name: AppRoutes.breathing,
        path: AppRoutes.breathing,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final emoji = extra?['emoji'] as String? ?? '😔';
          final thoughts = extra?['thoughts'] as String? ?? '';
          return _buildTransitionPage(
            state: state,
            child: BreathingScreen(emoji: emoji, thoughts: thoughts),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.freeDraw,
        path: AppRoutes.freeDraw,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final emoji = extra?['emoji'] as String? ?? '😔';
          final thoughts = extra?['thoughts'] as String? ?? '';
          return _buildTransitionPage(
            state: state,
            child: FreeDrawScreen(emoji: emoji, thoughts: thoughts),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.sudoku,
        path: AppRoutes.sudoku,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) {
              final cubit = sl<SudokuCubit>();
              unawaited(cubit.start());
              return cubit;
            },
            child: const SudokuScreen(),
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.savedDrawingViewer,
        path: AppRoutes.savedDrawingViewer,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _buildTransitionPage(
            state: state,
            child: SavedDrawingViewerScreen(
              drawing: extra['drawing'] as SavedDrawingEntity,
              onDelete: extra['onDelete'] as VoidCallback,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.weeklyLetter,
        path: AppRoutes.weeklyLetter,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<WeeklyLetterCubit>()..load(),
            child: const WeeklyLetterScreen(),
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.timeline,
        path: AppRoutes.timeline,
        pageBuilder: (context, state) => _buildTransitionPage(
          state: state,
          child: TimelineScreen(initialFocusDate: state.extra as DateTime?),
        ),
      ),
      GoRoute(
        name: AppRoutes.affirmation,
        path: AppRoutes.affirmation,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final emoji = extra?['emoji'] as String? ?? '😔';
          final thoughts = extra?['thoughts'] as String? ?? '';
          final destination =
              MoodChoiceDestination.fromName(extra?['destination'] as String?);
          return _buildTransitionPage(
            state: state,
            child: AffirmationScreen(
              emoji: emoji,
              thoughts: thoughts,
              destination: destination,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.streakCelebration,
        path: AppRoutes.streakCelebration,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final streakDays = extra?['streakDays'] as int? ?? 7;
          return _buildTransitionPage(
            state: state,
            child: StreakCelebrationScreen(streakDays: streakDays),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.savedQuotes,
        path: AppRoutes.savedQuotes,
        pageBuilder: (context, state) {
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => sl<SavedQuotesCubit>()..loadQuotes(),
              child: const SavedQuotesScreen(),
            ),
          );
        },
      ),
    ],
  );
}
