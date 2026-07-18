import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lueur_app/core/constants/app_sizes.dart';
import 'package:lueur_app/core/constants/app_spacing.dart';
import 'package:lueur_app/core/models/mood_type.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';

class MoodEntryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String preview;
  final Color sideColor;
  final DateTime date;
  final VoidCallback onTap;
  final bool isEmojiImage;

  const MoodEntryCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.preview,
    required this.sideColor,
    required this.date,
    required this.onTap,
    this.isEmojiImage = false,
  });

  Widget _buildEmojiWidget() {
    // 1. Unicode emoji → look up the matching mood illustration (same set
    //    used by the home mood picker), full color, no tint.
    final moodType = moodTypeFromEmoji(emoji);
    if (moodType != null) {
      final assetPath = moodType.assetPath;
      return assetPath.endsWith('.svg')
          ? SvgPicture.asset(assetPath, width: AppSizes.iconLg, height: AppSizes.iconLg)
          : Image.asset(assetPath, width: AppSizes.iconLg, height: AppSizes.iconLg, fit: BoxFit.contain);
    }
    // 2. Already an asset path (isEmojiImage = true)
    if (isEmojiImage) {
      return emoji.endsWith('.svg')
          ? SvgPicture.asset(emoji, width: AppSizes.iconLg, height: AppSizes.iconLg)
          : Image.asset(emoji, width: AppSizes.iconLg, height: AppSizes.iconLg, fit: BoxFit.contain);
    }
    // 3. Fallback: raw unicode text
    return RichText(text: TextSpan(text: emoji, style: TextStyle(fontSize: 24.sp)));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (DateUtils.isSameDay(date, now)) return 'Today';
    if (DateUtils.isSameDay(date, yesterday)) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final extraColors = context.extra;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.horizontalPaddingSm),
        decoration: BoxDecoration(
          color: extraColors.surfaceColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: extraColors.shadowColor!,
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sidebar
            Container(
              width: AppSizes.moodCardSidebarWidth,
              height: AppSizes.moodCardSidebarHeight,
              decoration: BoxDecoration(
                color: sideColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
              ),
            ),

            SizedBox(width: AppSpacing.spaceMd),

            // Emoji bubble
            Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: extraColors.cardBackgroundColor,
              ),
              alignment: Alignment.center,
              child: _buildEmojiWidget(),
            ),

            SizedBox(width: AppSpacing.spaceMd),

            // Title + preview + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: ThemeTextStyles.titleMedium(context),
                  ),
                  SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    preview,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: ThemeTextStyles.bodySmall(context),
                  ),
                  SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    "${_formatDate(date)} · ${DateFormat('h:mm a').format(date)}",
                    style: ThemeTextStyles.captionSmall(context),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: extraColors.tertiaryTextColor,
              size: AppSizes.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}
