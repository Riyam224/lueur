import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Card shown once the AI has wrapped up a chat session, offering a way
/// back to Home.
class ChatSessionEndCard extends StatelessWidget {
  const ChatSessionEndCard({super.key, required this.onBackToHome});

  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.all(AppSpacing.spaceLg),
      padding: EdgeInsets.all(AppSpacing.space2Xl),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: extra.borderColor ?? cs.outline),
        boxShadow: [
          BoxShadow(
            color: (extra.shadowColor ?? AppColors.overlayBlack)
                .withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🌿',
            style: TextStyle(
              fontSize: 32.sp,
              fontFamilyFallback: const [
                'Apple Color Emoji',
                'Noto Color Emoji',
              ],
            ),
          ),
          SizedBox(height: AppSpacing.spaceSm),
          Text(
            l10n.chatSessionEndGladMessage,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.headlineSmall(context).copyWith(
              color: cs.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.chatSessionEndSavedMessage,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.bodySmall(context).copyWith(
              color: extra.secondaryTextColor,
            ),
          ),
          SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBackToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonFill,
                foregroundColor: AppColors.whiteTextColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                l10n.chatBackToHomeButton,
                style: ThemeTextStyles.labelMedium(context).copyWith(
                  color: AppColors.whiteTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
