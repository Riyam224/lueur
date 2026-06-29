import 'package:flutter/material.dart';
import '../../../../core/styling/app_colors.dart';
import '../constants/onboarding_constants.dart';

/// Circular CTA button that advances pages or completes the onboarding flow.
/// Scales to 0.95 on press for tactile feedback.
class OnboardingNextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLastPage;

  const OnboardingNextButton({
    super.key,
    required this.onPressed,
    required this.isLastPage,
  });

  @override
  State<OnboardingNextButton> createState() => _OnboardingNextButtonState();
}

class _OnboardingNextButtonState extends State<OnboardingNextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const size = OnboardingConstants.nextButtonSize;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: OnboardingConstants.nextButtonScaleDuration,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.onboardingAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.isLastPage
                ? Icons.check_rounded
                : Icons.arrow_forward_rounded,
            color: AppColors.whiteTextColor,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}
