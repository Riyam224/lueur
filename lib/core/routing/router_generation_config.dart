import 'package:ai_therapist_app/core/injection/injection.dart';
import 'package:ai_therapist_app/core/navigation/main_shell_screen.dart';
import 'package:ai_therapist_app/core/routing/app_routes.dart';
import 'package:ai_therapist_app/features/affirmation/presentation/screens/affirmation_screen.dart';
import 'package:ai_therapist_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ai_therapist_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:ai_therapist_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ai_therapist_app/features/auth/presentation/screens/register_screen.dart';
import 'package:ai_therapist_app/features/breathing/presentation/screens/breathing_screen.dart';
import 'package:ai_therapist_app/features/chat/domain/entities/chat_message.dart';
import 'package:ai_therapist_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ai_therapist_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:ai_therapist_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ai_therapist_app/features/home/presentation/cubit/mood_cubit.dart';
import 'package:ai_therapist_app/features/home/presentation/cubit/mood_state.dart';
import 'package:ai_therapist_app/features/home/presentation/screens/home_screen.dart';
import 'package:ai_therapist_app/features/journal/presentation/screens/journal_history_screen.dart';
import 'package:ai_therapist_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:ai_therapist_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:ai_therapist_app/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:ai_therapist_app/features/quotes/presentation/screens/saved_quotes_screen.dart';
import 'package:ai_therapist_app/features/response/presentation/screens/response_ai_screen.dart';
import 'package:ai_therapist_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          child: const SplashScreen(),
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
                  child: const JournalHistoryScreen(),
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
          return _buildTransitionPage(
            state: state,
            child: BlocProvider(
              create: (_) => ChatCubit(
                repository: sl<ChatRepository>(),
                userId: userId,
                initialMessages: [
                  if (thoughts.isNotEmpty)
                    ChatMessage(role: 'user', content: thoughts),
                  if (aiResponse.isNotEmpty)
                    ChatMessage(role: 'assistant', content: aiResponse),
                ],
              ),
              child: ChatScreen(emoji: emoji),
            ),
          );
        },
      ),

      GoRoute(
        name: AppRoutes.breathing,
        path: AppRoutes.breathing,
        pageBuilder: (context, state) {
          final emoji = state.extra as String? ?? '😔';
          return _buildTransitionPage(
            state: state,
            child: BreathingScreen(emoji: emoji),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.affirmation,
        path: AppRoutes.affirmation,
        pageBuilder: (context, state) {
          final emoji = state.extra as String? ?? '😔';
          return _buildTransitionPage(
            state: state,
            child: AffirmationScreen(emoji: emoji),
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
