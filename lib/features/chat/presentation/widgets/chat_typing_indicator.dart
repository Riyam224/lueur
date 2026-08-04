import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// "Luna is typing" pill shown while waiting for an AI reply.
class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: AppSpacing.spaceLg,
          bottom: AppSpacing.spaceSm,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: extra.cardBackgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: (extra.shadowColor ?? AppColors.overlayBlack)
                  .withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.chatTypingLabel,
              style: ThemeTextStyles.labelSmall(context).copyWith(
                color: cs.primary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(width: 6.w),
            Image.asset(
              AppAssets.lunaCharacter,
              width: 22.w,
              height: 22.h,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
