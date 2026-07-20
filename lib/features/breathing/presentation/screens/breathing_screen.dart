// lib/features/breathing/presentation/screens/breathing_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/luna_check_in_prompt.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_phase.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_cubit.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_state.dart';

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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  Widget _ambientBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [
            AppColors.darkBackground,
            AppColors.darkSurface,
            AppColors.primaryDarkDeep,
          ]
        : const [
            AppColors.breathingGradientLavender,
            AppColors.breathingGradientCream,
            AppColors.breathingGradientPeach,
          ];
    final inkColor =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
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
                BreathingInProgress() =>
                  _buildInProgress(context, state, inkColor),
                BreathingFinished() => _buildFinished(context),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInProgress(
    BuildContext context,
    BreathingInProgress state,
    Color inkColor,
  ) {
    final isBreatheIn = state.phase == BreathingPhase.breatheIn;
    final phaseLabel = isBreatheIn ? 'Breathe in' : 'Breathe out';
    final ringColor = isBreatheIn
        ? AppColors.breathingGradientLavender
        : AppColors.breathingGradientPeach;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingXl,
      ),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.space3Xl),
          Text(
            'guided breathing',
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color: inkColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: 300.w,
            height: 300.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10.h,
                  left: 0,
                  child: _ambientBlob(
                    120.w,
                    AppColors.breathingGradientLavender.withValues(alpha: 0.4),
                  ),
                ),
                Positioned(
                  bottom: 10.h,
                  right: 0,
                  child: _ambientBlob(
                    140.w,
                    AppColors.breathingGradientPeach.withValues(alpha: 0.4),
                  ),
                ),
                // Cute concentric "ring" frame — a fixed colored disc, a
                // fixed cream padding ring, and a pulsing inner circle that
                // breathes with Luna, echoing a chunky breathing-app halo.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 260.w,
                  height: 260.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ringColor,
                  ),
                ),
                Container(
                  width: 220.w,
                  height: 220.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.breathingGradientCream,
                  ),
                ),
                AnimatedBuilder(
                  animation: _scale,
                  builder: (context, child) => Transform.scale(
                    scale: _scale.value,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 188.w,
                    height: 188.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ringColor.withValues(alpha: 0.9),
                          ringColor.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(14.w),
                    child: Image.asset(
                      AppAssets.lunaCharacter,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.spaceXl),
          Text(
            phaseLabel,
            key: ValueKey(phaseLabel),
            style: AppTextStyles.displayMedium(context).copyWith(
              color: inkColor,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.spaceMd),
          _buildPhaseDots(isBreatheIn, inkColor),
          const Spacer(),
          _buildProgress(context, state, inkColor),
          SizedBox(height: AppSpacing.spaceLg),
        ],
      ),
    );
  }

  Widget _buildPhaseDots(bool isBreatheIn, Color inkColor) {
    Widget dot(bool active) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: active ? 20.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : inkColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(isBreatheIn),
        dot(!isBreatheIn),
      ],
    );
  }

  Widget _buildProgress(
    BuildContext context,
    BreathingInProgress state,
    Color inkColor,
  ) {
    final total = state.config.totalDurationSeconds;
    final progress = (state.elapsedSeconds / total).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.4),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        SizedBox(height: AppSpacing.spaceSm),
        Text(
          '${_formatTime(state.elapsedSeconds)} / ${_formatTime(total)}',
          style: ThemeTextStyles.bodySmall(context).copyWith(
            color: inkColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFinished(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPaddingXl,
        ),
        child: LunaCheckInPrompt(
          onTalkToLuna: _goToTalkToLuna,
          onDismiss: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}
