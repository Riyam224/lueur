import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
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
    return SizedBox(
      width: double.infinity,
      height: AuthConstants.ctaButtonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onboardingAccent,
          foregroundColor: AppColors.whiteTextColor,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: isLoading
            ? SizedBox(
                width: AppSizes.iconLg,
                height: AppSizes.iconLg,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.whiteTextColor,
                ),
              )
            : Text(label, style: AppTextStyles.buttonEmphasis(context)),
      ),
    );
  }
}
