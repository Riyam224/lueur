// lib/features/breathing/presentation/screens/breathing_screen.dart

import 'package:ai_therapist_app/core/constants/app_sizes.dart';
import 'package:ai_therapist_app/core/constants/app_spacing.dart';
import 'package:ai_therapist_app/core/routing/app_routes.dart';
import 'package:ai_therapist_app/core/styling/app_assets.dart';
import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/styling/theme_extensions.dart';
import 'package:ai_therapist_app/core/styling/theme_text_styles.dart';
import 'package:ai_therapist_app/features/breathing/presentation/widgets/breathing_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
// 

class BreathingScreen extends StatefulWidget {
  final String emoji;

  const BreathingScreen({super.key, required this.emoji});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;

  final ValueNotifier<int> _currentRound = ValueNotifier<int>(1);
  final int _totalRounds = 3;
  final ValueNotifier<String> _phase = ValueNotifier<String>('Breathe in');
  final ValueNotifier<String> _subText =
      ValueNotifier<String>('Take a deep breath for 4 seconds');
  final ValueNotifier<Color> _circleColor =
      ValueNotifier<Color>(AppColors.breathInColor);
  final ValueNotifier<bool> _isRunning = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFinished = ValueNotifier<bool>(false);

  static final List<Map<String, Object>> _phases = [
    {
      'name': 'Breathe in',
      'seconds': 4,
      'color': AppColors.breathInColor,
      'sub': 'Take a deep breath slowly',
    },
    {
      'name': 'Hold',
      'seconds': 7,
      'color': AppColors.breathHoldColor,
      'sub': 'Hold your breath gently',
    },
    {
      'name': 'Breathe out',
      'seconds': 8,
      'color': AppColors.breathOutColor,
      'sub': 'Release slowly and completely',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );
  }

  String get _lunaMessage {
    if (_isFinished.value) return 'You did so well. Take a moment to feel the calm 🌸';
    if (_isRunning.value) {
      switch (_phase.value) {
        case 'Breathe in':
          return 'Slowly breathe in through your nose…';
        case 'Hold':
          return 'Hold gently… you\'re doing great 🌿';
        default:
          return 'Let it all out, slowly and completely…';
      }
    }
    return 'I\'ll guide you through every breath. Ready when you are 🌿';
  }

  Future<void> _startExercise() async {
    _isRunning.value = true;

    for (int round = 1; round <= _totalRounds; round++) {
      if (!mounted) return;
      _currentRound.value = round;

      for (final phase in _phases) {
        if (!mounted) return;

        HapticFeedback.lightImpact();

        _phase.value = phase['name'] as String;
        _subText.value = phase['sub'] as String;
        _circleColor.value = phase['color'] as Color;

        _controller?.duration = Duration(seconds: phase['seconds'] as int);

        if (phase['name'] == 'Breathe in') {
          _controller?.forward(from: 0);
        } else if (phase['name'] == 'Breathe out') {
          _controller?.reverse(from: 1);
        }

        await Future.delayed(Duration(seconds: phase['seconds'] as int));
      }
    }

    if (!mounted) return;
    HapticFeedback.mediumImpact();
    _isFinished.value = true;

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      context.go(AppRoutes.affirmation, extra: widget.emoji);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _currentRound.dispose();
    _phase.dispose();
    _subText.dispose();
    _circleColor.dispose();
    _isRunning.dispose();
    _isFinished.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingXl,
          ),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.space3Xl + AppSpacing.spaceSm),
              Text(
                'Breathe with Luna 🌿',
                style: ThemeTextStyles.headlineSmall(context).copyWith(
                  color: context.extra.primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.spaceSm),
              Text(
                '4-7-8 breathing for instant calm',
                style: ThemeTextStyles.bodyMedium(context).copyWith(
                  color: context.extra.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.spaceLg),
              // ── Luna AI helper ────────────────────────────────────────
              AnimatedBuilder(
                animation: Listenable.merge([_isRunning, _isFinished, _phase]),
                builder: (context, _) {
                  return Row(
                    children: [
                      Container(
                        width: AppSizes.avatarLg,
                        height: AppSizes.avatarLg,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer
                              .withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            AppAssets.lunaIllustration,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.spaceMd),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.spaceMd,
                            vertical: AppSpacing.spaceSm,
                          ),
                          decoration: BoxDecoration(
                            color: context.extra.cardBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(4),
                            ),
                            border: Border.all(
                              color: context.extra.borderColor ??
                                  AppColors.lightBorder,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Text(
                              _lunaMessage,
                              key: ValueKey(_lunaMessage),
                              style: ThemeTextStyles.bodySmall(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: AppSpacing.spaceLg),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimation,
                  _phase,
                  _circleColor,
                ]),
                builder: (context, child) {
                  return Center(
                    child: BreathingCircle(
                      scale: _scaleAnimation!.value,
                      color: _circleColor.value,
                      phaseText: _phase.value,
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.space3Xl),
              ValueListenableBuilder<String>(
                valueListenable: _phase,
                builder: (context, phase, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      phase,
                      key: ValueKey(phase),
                      style: ThemeTextStyles.headlineSmall(context).copyWith(
                        color: context.extra.primaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.spaceSm),
              ValueListenableBuilder<String>(
                valueListenable: _subText,
                builder: (context, subText, child) {
                  return Text(
                    subText,
                    style: ThemeTextStyles.bodyMedium(context).copyWith(
                      color: context.extra.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              SizedBox(height: AppSpacing.spaceLg),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _isRunning,
                  _isFinished,
                  _currentRound,
                ]),
                builder: (context, child) {
                  if (_isRunning.value && !_isFinished.value) {
                    return Text(
                      'Round ${_currentRound.value} of $_totalRounds',
                      style: ThemeTextStyles.bodySmall(context).copyWith(
                        color: context.extra.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }

                  if (_isFinished.value) {
                    return Text(
                      'Well done! 🌸',
                      style: ThemeTextStyles.labelLarge(context).copyWith(
                        color: context.extra.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              SizedBox(height: AppSpacing.space3Xl),
              AnimatedBuilder(
                animation: Listenable.merge([_isRunning, _isFinished]),
                builder: (context, child) {
                  if (_isRunning.value || _isFinished.value) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: AppSpacing.space3Xl + AppSpacing.space2Xl,
                        child: ElevatedButton(
                          onPressed: _startExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.extra.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Start Exercise',
                            style: ThemeTextStyles.whiteButton(context).copyWith(
                              color: context.extra.onPrimaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.spaceMd),
                      TextButton(
                        onPressed: () => context.go(
                          AppRoutes.affirmation,
                          extra: widget.emoji,
                        ),
                        child: Text(
                          'Skip',
                          style: ThemeTextStyles.bodyMedium(context).copyWith(
                            color: context.extra.secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: AppSpacing.space3Xl),
            ],
          ),
        ),
      ),
    );
  }
}
