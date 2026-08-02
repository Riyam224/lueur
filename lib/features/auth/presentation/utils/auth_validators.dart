import 'package:flutter/widgets.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Shared field-level validation for the login/register/forgot-password
/// screens. Returns a localized error string, or null when valid.
class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    if (value.trim().isEmpty) return l10n.authFieldRequired;
    if (!_emailPattern.hasMatch(value.trim())) return l10n.authEmailInvalid;
    return null;
  }

  static String? password(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    if (value.isEmpty) return l10n.authFieldRequired;
    if (value.length < AuthConstants.passwordShortLength) {
      return l10n.authPasswordTooShort;
    }
    return null;
  }

  static String? confirmPassword(
    BuildContext context,
    String password,
    String confirmation,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (confirmation.isEmpty) return l10n.authFieldRequired;
    if (confirmation != password) return l10n.authConfirmPasswordMismatch;
    return null;
  }

  static String? required(BuildContext context, String value) {
    if (value.trim().isEmpty) return AppLocalizations.of(context)!.authFieldRequired;
    return null;
  }
}
