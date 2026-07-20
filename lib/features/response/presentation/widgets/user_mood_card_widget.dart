import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// User mood card with pink background showing emoji and thoughts
class UserMoodCardWidget extends StatelessWidget {
  final String emoji;
  final String thoughts;
  final bool isEmojiImage;

  const UserMoodCardWidget({
    super.key,
    required this.emoji,
    required this.thoughts,
    this.isEmojiImage = false,
  });

  Widget _buildMoodIcon() {
    // 1. Unicode emoji → the matching mood illustration (same set used on
    //    the home mood picker), full color, no tint.
    final moodType = moodTypeFromEmoji(emoji);
    if (moodType != null) {
      final assetPath = moodType.assetPath;
      return assetPath.endsWith('.svg')
          ? SvgPicture.asset(assetPath, width: 32.w, height: 32.h)
          : Image.asset(assetPath, width: 32.w, height: 32.h);
    }
    // 2. Already an asset path (isEmojiImage = true)
    if (isEmojiImage) {
      return emoji.endsWith('.svg')
          ? SvgPicture.asset(emoji, width: 32.w, height: 32.h)
          : Image.asset(emoji, width: 32.w, height: 32.h);
    }
    // 3. Fallback: raw unicode text
    return Text(
      emoji,
      style: TextStyle(
        fontFamily: AppFonts.mainFontName,
        fontFamilyFallback: const [
          'Apple Color Emoji',
          'Noto Color Emoji',
          'Segoe UI Emoji',
        ],
        fontSize: 32.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.space2Xl),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Label
          Text(
            'YOUR MOOD',
            style: ThemeTextStyles.labelSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.spaceMd),

          // Emoji and Thoughts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              _buildMoodIcon(),
              SizedBox(width: AppSpacing.spaceMd),

              // Thoughts
              Expanded(
                child: Text(
                  thoughts,
                  style: ThemeTextStyles.bodyMedium(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
