import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// A square confirmation dialog shown right after a successful login or
/// registration — Luna's illustration plus a short "you're in" message.
/// Auto-dismisses itself; the caller awaits [show] then navigates on.
class AuthSuccessDialog extends StatefulWidget {
  const AuthSuccessDialog({super.key});

  static const _visibleDuration = Duration(milliseconds: 1400);

  /// Shows the dialog and resolves once it has auto-dismissed.
  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AuthSuccessDialog(),
      );

  @override
  State<AuthSuccessDialog> createState() => _AuthSuccessDialogState();
}

class _AuthSuccessDialogState extends State<AuthSuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(AuthSuccessDialog._visibleDuration, () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extra = context.extra;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      backgroundColor: extra.cardBackgroundColor,
      child: SizedBox(
        width: 240.w,
        height: 240.w,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.lunaCharacter,
                width: 96.w,
                height: 96.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: AppSpacing.spaceMd),
              Text(
                l10n.authSuccessTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall(context)
                    .copyWith(color: extra.primaryTextColor),
              ),
              SizedBox(height: AppSpacing.spaceSm),
              Text(
                l10n.authSuccessMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(color: extra.secondaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
