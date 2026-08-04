import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:lueur/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Submit button, "or" divider, Google sign-up, and "already have an
/// account" link shown below the register form fields.
class RegisterActionsSection extends StatelessWidget {
  const RegisterActionsSection({
    super.key,
    required this.isLoading,
    required this.borderColor,
    required this.secondaryText,
    required this.textPrimary,
    required this.primaryColor,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.onGoToLogin,
  });

  final bool isLoading;
  final Color borderColor;
  final Color secondaryText;
  final Color textPrimary;
  final Color primaryColor;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGoToLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        AuthPrimaryButton(
          label: l10n.registerCta,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
        SizedBox(height: AppSpacing.sectionSpacingSm),
        AuthOrDivider(lineColor: borderColor, textColor: secondaryText),
        SizedBox(height: AppSpacing.sectionSpacingSm),
        GoogleSignInButton(
          label: l10n.authSignUpWithGoogle,
          borderColor: borderColor,
          foregroundColor: textPrimary,
          onPressed: onGoogleSignIn,
        ),
        SizedBox(height: AuthConstants.googleToFooterSpacing),
        AuthFooterLink(
          prompt: l10n.registerSignInPrompt,
          action: l10n.registerSignInAction,
          promptColor: secondaryText,
          actionColor: primaryColor,
          onTap: onGoToLogin,
        ),
      ],
    );
  }
}
