import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// "Continue as guest" text button shown at the bottom of the login and
/// register screens.
class AuthGuestEntryButton extends StatelessWidget {
  const AuthGuestEntryButton({
    super.key,
    required this.secondaryText,
    required this.onPressed,
  });

  final Color secondaryText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: secondaryText,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.spaceSm,
            horizontal: AppSpacing.spaceMd,
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.authContinueAsGuest,
          style: AppTextStyles.caption(context).copyWith(
            color: secondaryText,
            decoration: TextDecoration.underline,
            decorationColor: secondaryText,
          ),
        ),
      ),
    );
  }
}
