import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Eyebrow label, big streak-day number, and "days with Luna" subtitle at
/// the top of the streak celebration screen.
class StreakCelebrationHeader extends StatelessWidget {
  const StreakCelebrationHeader({
    super.key,
    required this.streakDays,
    required this.eyebrowLabel,
    required this.subtitle,
  });

  final int streakDays;
  final String eyebrowLabel;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          eyebrowLabel.toUpperCase(),
          style: ThemeTextStyles.whiteCaption(context).copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.spaceXs),
        Text(
          '$streakDays',
          style: TextStyle(
            fontFamily: AppFonts.mainFontName,
            fontSize: 72.sp,
            fontWeight: FontWeight.w800,
            height: 1.0,
            color: AppColors.whiteTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.spaceXs),
        Text(
          subtitle,
          style: ThemeTextStyles.whiteBody(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
