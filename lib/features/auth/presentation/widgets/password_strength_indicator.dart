import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/styling/app_text_styles.dart';
import 'package:ai_therapist_app/core/utils/app_strings.dart';
import 'package:ai_therapist_app/features/auth/presentation/constants/auth_constants.dart';
import 'package:flutter/material.dart';

/// Password strength bucket derived from raw password length.
enum PasswordStrength { none, weak, medium, strong }

extension PasswordStrengthX on PasswordStrength {
  double get value => switch (this) {
        PasswordStrength.none => 0,
        PasswordStrength.weak => AuthConstants.passwordStrengthWeak,
        PasswordStrength.medium => AuthConstants.passwordStrengthMedium,
        PasswordStrength.strong => AuthConstants.passwordStrengthStrong,
      };

  String get label => switch (this) {
        PasswordStrength.none => '',
        PasswordStrength.weak => AppStrings.passwordStrengthTooShort,
        PasswordStrength.medium => AppStrings.passwordStrengthGettingThere,
        PasswordStrength.strong => AppStrings.passwordStrengthStrong,
      };

  static PasswordStrength fromPassword(String value) {
    if (value.isEmpty) return PasswordStrength.none;
    if (value.length < AuthConstants.passwordShortLength) {
      return PasswordStrength.weak;
    }
    if (value.length < AuthConstants.passwordMediumLength) {
      return PasswordStrength.medium;
    }
    return PasswordStrength.strong;
  }
}

/// Thin progress bar + label showing how strong the typed password is.
/// Renders nothing when [strength] is [PasswordStrength.none].
class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;
  final Color backgroundColor;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.backgroundColor,
  });

  Color _color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (strength) {
      PasswordStrength.none => cs.error,
      PasswordStrength.weak => cs.error,
      PasswordStrength.medium => AppColors.warningAmber,
      PasswordStrength.strong => AppColors.onboardingAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    final color = _color(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AuthConstants.strengthBarRadius),
          child: LinearProgressIndicator(
            value: strength.value,
            minHeight: AuthConstants.strengthBarHeight,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        SizedBox(height: AuthConstants.strengthBarToLabelSpacing),
        Text(
          strength.label,
          style: AppTextStyles.strengthLabel(context).copyWith(color: color),
        ),
      ],
    );
  }
}
