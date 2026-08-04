import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Centered emoji + title + message used for both the "no entries yet" and
/// "no results for these filters" states on the timeline.
class TimelineEmptyStateWidget extends StatelessWidget {
  const TimelineEmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    required this.messageColor,
  });

  final String emoji;
  final String title;
  final String message;
  final Color messageColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 40.sp)),
            SizedBox(height: AppSpacing.spaceMd),
            Text(
              title,
              style: ThemeTextStyles.headlineSmall(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spaceSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.bodyMedium(context)
                  .copyWith(color: messageColor),
            ),
          ],
        ),
      ),
    );
  }
}
