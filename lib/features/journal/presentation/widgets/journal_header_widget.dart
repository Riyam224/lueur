import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

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
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.journalTitle,
            overflow: TextOverflow.ellipsis,
            style: ThemeTextStyles.headlineMedium(context),
          ),
        ),
        SizedBox(width: AppSpacing.spaceSm),
        Row(
          children: [
            if (onDeleteAll != null) ...[
              GestureDetector(
                onTap: onDeleteAll,
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.primary,
                  size: AppSizes.iconSm,
                ),
              ),
              SizedBox(width: AppSpacing.spaceMd),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
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
