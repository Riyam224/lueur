import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';

/// Full-width pill CTA button used for login/register submit actions.
/// Shows a spinner instead of [label] while [isLoading] is true.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: isLoading ? null : onPressed,
      pressedScale: 0.97,
      child: Container(
        width: double.infinity,
        height: AuthConstants.ctaButtonHeight,
        decoration: BoxDecoration(
          color: AppColors.primaryButtonFill,
          borderRadius: BorderRadius.circular(AuthConstants.ctaButtonHeight),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryButtonFill.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: AppSizes.iconLg,
                height: AppSizes.iconLg,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.whiteTextColor,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.buttonEmphasis(context)
                    .copyWith(color: AppColors.whiteTextColor),
              ),
      ),
    );
  }
}
