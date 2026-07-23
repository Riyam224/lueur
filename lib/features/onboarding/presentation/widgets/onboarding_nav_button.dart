import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/onboarding/presentation/constants/onboarding_constants.dart';

/// Small circular back/forward arrow button used in the onboarding bottom
/// nav row. Scales down on press for tactile feedback; fades out and
/// ignores taps when [enabled] is false (e.g. the back arrow on page one).
class OnboardingNavButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final bool enabled;

  const OnboardingNavButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.color,
    this.enabled = true,
  });

  @override
  State<OnboardingNavButton> createState() => _OnboardingNavButtonState();
}

class _OnboardingNavButtonState extends State<OnboardingNavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const size = OnboardingConstants.navArrowButtonSize;

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: AnimatedOpacity(
        opacity: widget.enabled ? 1.0 : 0.0,
        duration: OnboardingConstants.pageTransitionDuration,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.9 : 1.0,
            duration: OnboardingConstants.navArrowScaleDuration,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: AppColors.whiteTextColor,
                size: size * 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
