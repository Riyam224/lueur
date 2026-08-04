import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/plant/presentation/widgets/frosted_card.dart';

/// Affirmation card + "keep going" call-to-action shown at the bottom of
/// the streak celebration screen.
class StreakCelebrationFooter extends StatelessWidget {
  const StreakCelebrationFooter({
    super.key,
    required this.affirmation,
    required this.buttonLabel,
    required this.onKeepGoing,
  });

  final String affirmation;
  final String buttonLabel;
  final VoidCallback onKeepGoing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FrostedCard(
          child: Text(
            affirmation,
            style: ThemeTextStyles.whiteBody(context),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: AppSpacing.spaceXl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onKeepGoing,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.whiteTextColor,
              foregroundColor: AppColors.celebrationGradientLightEnd,
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.verticalPaddingLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              ),
            ),
            child: Text(
              buttonLabel,
              style: ThemeTextStyles.labelLarge(context).copyWith(
                color: AppColors.celebrationGradientLightEnd,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
