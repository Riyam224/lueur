import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/l10n/app_localizations.dart';

enum GuestWarningChoice { continueAsGuest, registerInstead }

/// One-time confirmation shown at the point where a temporary guest session
/// begins. Closing the dialog leaves the user on the current auth screen.
class GuestWarningDialog extends StatelessWidget {
  const GuestWarningDialog({super.key});

  static Future<GuestWarningChoice?> show(BuildContext context) =>
      showDialog<GuestWarningChoice>(
        context: context,
        builder: (_) => const GuestWarningDialog(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extra = context.extra;

    return Dialog(
      backgroundColor: extra.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.lunaCharacter,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: AppSpacing.spaceMd),
              Text(
                l10n.guestWarningTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: extra.primaryTextColor,
                ),
              ),
              SizedBox(height: AppSpacing.spaceSm),
              Text(
                l10n.guestWarningMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: extra.secondaryTextColor,
                ),
              ),
              SizedBox(height: AppSpacing.spaceXl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    GuestWarningChoice.continueAsGuest,
                  ),
                  child: Text(l10n.authContinueAsGuest),
                ),
              ),
              SizedBox(height: AppSpacing.spaceSm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(
                  GuestWarningChoice.registerInstead,
                ),
                child: Text(l10n.guestWarningRegisterInstead),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
