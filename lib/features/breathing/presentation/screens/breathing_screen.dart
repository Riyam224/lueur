import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/luna_check_in_prompt.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_phase.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_cubit.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_state.dart';
import 'package:lueur/features/breathing/presentation/widgets/breathing_in_progress_content.dart';

class BreathingScreen extends StatelessWidget {
  final String emoji;
  final String thoughts;

  const BreathingScreen({
    super.key,
    required this.emoji,
    this.thoughts = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BreathingCubit>()..start(),
      child: _BreathingView(emoji: emoji, thoughts: thoughts),
    );
  }
}

class _BreathingView extends StatefulWidget {
  final String emoji;
  final String thoughts;

  const _BreathingView({required this.emoji, required this.thoughts});

  @override
  State<_BreathingView> createState() => _BreathingViewState();
}

/// Scoped exception to the app's "no looping animation" rule: this loop is
/// the paced-breathing instruction itself (functional), not decoration, and
/// it stops the moment the exercise finishes.
class _BreathingViewState extends State<_BreathingView>
    with SingleTickerProviderStateMixin {
  static const double _restScale = 1.0;
  static const double _peakScale = 1.12;

  late final AnimationController _scaleController;
  late final Animation<double> _scale;
  BreathingPhase? _lastSyncedPhase;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scale = Tween<double>(begin: _restScale, end: _peakScale).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _syncAnimation(BreathingInProgress state) {
    if (_lastSyncedPhase == state.phase) return;
    _lastSyncedPhase = state.phase;

    if (state.phase == BreathingPhase.breatheIn) {
      _scaleController.duration =
          Duration(seconds: state.config.breatheInSeconds);
      _scaleController.forward(from: _scaleController.value);
    } else {
      _scaleController.duration =
          Duration(seconds: state.config.breatheOutSeconds);
      _scaleController.reverse(from: _scaleController.value);
    }
  }

  void _goToTalkToLuna() {
    context.push(
      AppRoutes.chat,
      extra: {
        'userId': sl<FirebaseAuth>().currentUser?.uid ?? '',
        'emoji': widget.emoji,
        'thoughts': widget.thoughts,
        'aiResponse': '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<BreathingCubit, BreathingState>(
          listenWhen: (previous, current) =>
              (current is BreathingInProgress &&
                  (previous is! BreathingInProgress ||
                      previous.phase != current.phase)) ||
              current is BreathingFinished,
          listener: (context, state) {
            if (state is BreathingInProgress) {
              _syncAnimation(state);
            } else if (state is BreathingFinished) {
              _scaleController.stop();
              _scaleController.value = 0;
            }
          },
          // The cubit ticks `elapsedSeconds` once per second while in
          // progress; only rebuild this (heavier) tree on type/phase changes
          // and let the progress bar re-render itself via its own selector.
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              (previous is BreathingInProgress &&
                  current is BreathingInProgress &&
                  previous.phase != current.phase),
          builder: (context, state) {
            return switch (state) {
              BreathingLoading() => const SizedBox.shrink(),
              BreathingError(:final message) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: ThemeTextStyles.bodyMedium(context),
                    ),
                  ),
                ),
              BreathingInProgress() => BreathingInProgressContent(
                  state: state,
                  inkColor: inkColor,
                  scale: _scale,
                ),
              BreathingFinished() => Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPaddingXl,
                    ),
                    child: LunaCheckInPrompt(
                      onTalkToLuna: _goToTalkToLuna,
                      onDismiss: () => context.go(AppRoutes.home),
                    ),
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}
