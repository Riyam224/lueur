import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur_app/core/styling/app_fonts.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';

/// Row of 3 stat cards: total entries, this week, day streak
class ProfileStatsWidget extends StatelessWidget {
  final int totalEntries;
  final int thisWeek;
  final int dayStreak;

  const ProfileStatsWidget({
    super.key,
    required this.totalEntries,
    required this.thisWeek,
    required this.dayStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '$totalEntries',
          label: 'Total entries',
        ),
        SizedBox(width: 10.w),
        _StatCard(
          value: '$thisWeek',
          label: 'This week',
        ),
        SizedBox(width: 10.w),
        // Emoji separated into its own span so it bypasses the Urbanist font
        // and renders with the system emoji font (Apple Color Emoji / Noto)
        _StatCard(
          value: '$dayStreak',
          label: 'Day streak',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: context.extra.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: context.extra.shadowColor!.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontFamily: AppFonts.mainFontName,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: context.extra.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Text(label, style: ThemeTextStyles.captionSmall(context)),
          ],
        ),
      ),
    );
  }
}
