import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Action buttons for saving or following up on the conversation
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onTalkAgain;
  final String saveLabel;
  final String talkAgainLabel;

  const ActionButtonsWidget({
    super.key,
    this.onSave,
    this.onTalkAgain,
    this.saveLabel = 'Save to journal',
    this.talkAgainLabel = 'Talk again',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Save to journal button (filled)
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonFill,
              foregroundColor: AppColors.whiteTextColor,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceLg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: Text(
              saveLabel,
              style: ThemeTextStyles.labelMedium(context).copyWith(
                color: AppColors.whiteTextColor,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.spaceMd),

        // Talk again button (outlined)
        Expanded(
          child: OutlinedButton(
            onPressed: onTalkAgain,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceLg),
              side: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              talkAgainLabel,
              style: ThemeTextStyles.labelMedium(context).copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
