import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Shown in place of the generic error state when a guest tries to talk
/// with Luna — this is an expected state, not a failure, so it gets warm
/// copy and a clear call to action instead of retry/error framing.
class ResponseGuestBlockedState extends StatelessWidget {
  const ResponseGuestBlockedState({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: AppSizes.iconXl,
            ),
            SizedBox(height: AppSpacing.spaceMd),
            Text(
              l10n.responseGuestBlockedTitle,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.titleMedium(context),
            ),
            SizedBox(height: AppSpacing.spaceSm),
            Text(
              l10n.responseGuestBlockedMessage,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.bodyMedium(context),
            ),
            SizedBox(height: AppSpacing.spaceLg),
            ElevatedButton(
              onPressed: onSignIn,
              child: Text(l10n.responseGuestBlockedButton),
            ),
          ],
        ),
      ),
    );
  }
}
