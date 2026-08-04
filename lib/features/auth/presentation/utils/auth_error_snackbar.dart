import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';

/// Floating error snackbar shared by the login/register screens'
/// [AuthError] state handling.
void showAuthErrorSnackBar(BuildContext context, String message) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: cs.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      ),
    ),
  );
}
