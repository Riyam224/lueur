import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Mandatory age-confirmation modal shown once, right after a brand-new
/// account is created via a path that has no prior age gate (Google
/// sign-in on either the login or register screen). Not dismissible via
/// the back gesture or barrier tap — the caller must get an explicit
/// `true`/`false` answer, since declining triggers an account rollback.
class AgeConfirmationDialog extends StatelessWidget {
  const AgeConfirmationDialog({super.key});

  /// Resolves to `true` if the user confirmed, `false` if they declined.
  /// Never resolves to `null` — the dialog cannot be dismissed without a choice.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AgeConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extra = context.extra;

    return PopScope(
      canPop: false,
      child: Dialog(
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
                  l10n.ageConfirmationDialogTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall(context)
                      .copyWith(color: extra.primaryTextColor),
                ),
                SizedBox(height: AppSpacing.spaceSm),
                Text(
                  l10n.ageConfirmationDialogMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(color: extra.secondaryTextColor),
                ),
                SizedBox(height: AppSpacing.spaceXl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.ageConfirmationDialogConfirm),
                  ),
                ),
                SizedBox(height: AppSpacing.spaceSm),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.ageConfirmationDialogDecline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
