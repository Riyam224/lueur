import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/response/presentation/widgets/mood_asset_image.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Floating modal shown after picking an after-feeling emoji, with a
/// different tone/action for the "still sad" (negative) option.
class AfterFeelingMoodModal extends StatelessWidget {
  const AfterFeelingMoodModal({
    super.key,
    required this.asset,
    required this.label,
    required this.message,
    required this.isNegative,
    this.onTalkAgain,
  });

  final String asset;
  final String label;
  final String message;
  final bool isNegative;
  final VoidCallback? onTalkAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Material(
        color: AppColors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28.w),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.overlayBlack.withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji face — on dark mode wrap in a light circle so SVG
              // fills show up.
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final img = MoodAssetImage(asset: asset, size: 72.w);
                  if (!isDark) return img;
                  return Container(
                    width: 88.w,
                    height: 88.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.softLavender,
                    ),
                    alignment: Alignment.center,
                    child: img,
                  );
                },
              ),
              SizedBox(height: 16.h),
              Text(
                isNegative
                    ? l10n.afterFeelingTakeYourTime
                    : l10n.afterFeelingYouAreFeeling(label),
                style: ThemeTextStyles.titleLarge(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                style: ThemeTextStyles.bodySmall(context).copyWith(
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isNegative ? onTalkAgain : () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonFill,
                    foregroundColor: AppColors.whiteTextColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    isNegative
                        ? l10n.afterFeelingTalkToLunaAgain
                        : l10n.afterFeelingThankYouLuna,
                    style: ThemeTextStyles.labelMedium(context).copyWith(
                      color: AppColors.whiteTextColor,
                    ),
                  ),
                ),
              ),
              if (isNegative) ...[
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.afterFeelingImOkay,
                    style: ThemeTextStyles.bodySmall(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
