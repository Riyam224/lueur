import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/navigation/main_shell_screen.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/features/affirmation/presentation/screens/affirmation_screen.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/screens/login_screen.dart';
import 'package:lueur/features/auth/presentation/screens/register_screen.dart';
import 'package:lueur/features/breathing/presentation/screens/breathing_screen.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:lueur/features/chat/presentation/screens/chat_screen.dart';
import 'package:lueur/features/draw/presentation/screens/free_draw_screen.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/home/presentation/screens/home_screen.dart';
import 'package:lueur/features/journal/presentation/screens/journal_grid_screen.dart';
import 'package:lueur/features/mood_choice/presentation/screens/mood_choice_screen.dart';
import 'package:lueur/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:lueur/features/profile/presentation/screens/profile_screen.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/screens/saved_quotes_screen.dart';
import 'package:lueur/features/response/presentation/screens/response_ai_screen.dart';
import 'package:lueur/features/splash/presentation/screens/splash_screen.dart';

class RouterGenerationConfig {
  static CustomTransitionPage _buildTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splash,
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
              listenWhen: (previous, current) =>
                  current is AuthUnauthenticated,
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
                  child: BlocProvider(
                    create: (_) => sl<SavedQuotesCubit>()..loadQuotes(),
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
          final needsAutoSend = dayHistory == null &&
              thoughts.isNotEmpty &&
              aiResponse.isEmpty;
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
        name: AppRoutes.moodChoice,
        path: AppRoutes.moodChoice,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final emoji = extra?['emoji'] as String? ?? '😔';
          final thoughts = extra?['thoughts'] as String? ?? '';
          return _buildTransitionPage(
            state: state,
            child: MoodChoiceScreen(emoji: emoji, thoughts: thoughts),
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
        name: AppRoutes.affirmation,
        path: AppRoutes.affirmation,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final emoji = extra?['emoji'] as String? ?? '😔';
          final thoughts = extra?['thoughts'] as String? ?? '';
          return _buildTransitionPage(
            state: state,
            child: AffirmationScreen(emoji: emoji, thoughts: thoughts),
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
