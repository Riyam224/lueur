import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Resolves a stable, unlocalized auth failure code (as returned by
/// [AuthRepositoryImpl]) to Luna's localized copy for it. Falls back to a
/// generic message for any code this switch doesn't recognize.
String localizeAuthErrorCode(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context)!;
  return switch (code) {
    'user-not-found' => l10n.authErrorUserNotFound,
    'wrong-password' => l10n.authErrorWrongPassword,
    'email-already-in-use' => l10n.authErrorEmailInUse,
    'invalid-email' => l10n.authErrorInvalidEmail,
    'weak-password' => l10n.authErrorWeakPassword,
    'user-disabled' => l10n.authErrorUserDisabled,
    'too-many-requests' => l10n.authErrorTooManyRequests,
    'network-request-failed' => l10n.authErrorNetworkFailed,
    'login-failed' => l10n.authErrorLoginFailed,
    'register-failed' => l10n.authErrorRegisterFailed,
    'logout-failed' => l10n.authErrorLogoutFailed,
    'google-sync-failed' => l10n.authErrorGoogleSyncFailed,
    'google-sign-in-failed' => l10n.authErrorGoogleSignInFailed,
    'reset-email-failed' => l10n.authErrorResetEmailFailed,
    'sync-language-failed' => l10n.authErrorSyncLanguageFailed,
    _ => l10n.authErrorGeneric,
  };
}

/// Floating error snackbar shared by the login/register screens'
/// [AuthError] state handling.
void showAuthErrorSnackBar(BuildContext context, String errorCode) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(localizeAuthErrorCode(context, errorCode)),
      backgroundColor: cs.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      ),
    ),
  );
}
