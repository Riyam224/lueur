import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/styling/theme_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "My Journal" title + entry count badge
class JournalHeaderWidget extends StatelessWidget {
  final int entryCount;
  final VoidCallback? onDeleteAll;

  const JournalHeaderWidget({
    super.key,
    required this.entryCount,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('My Journal', style: ThemeTextStyles.headlineMedium(context)),
        Row(
          children: [
            if (onDeleteAll != null) ...[
              GestureDetector(
                onTap: onDeleteAll,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '$entryCount entries',
                style: ThemeTextStyles.bodySmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
