import 'package:flutter/material.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Shows Luna's friendly "you're offline" snackbar — shared by every flow
/// that surfaces a [NetworkOfflineFailure] instead of the raw connection
/// error (chat send, mood check-in, mood response retry).
void showOfflineSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)!.chatOfflineSnack),
    ),
  );
}
