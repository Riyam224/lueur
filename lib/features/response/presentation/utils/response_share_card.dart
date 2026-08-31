import 'package:flutter/material.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

// Share-card export is rendered off-screen at a fixed pixel size (it becomes
// a PNG, not on-screen UI) — intentionally skips flutter_screenutil scaling.
const double shareCardWidth = 1080;
const double _shareCardPadding = 64;
const double _shareCardHeadingGap = 24;
const double _shareCardBodyGap = 40;

/// Builds the off-screen widget captured as a PNG when a user shares
/// Luna's response.
Widget buildResponseShareCard(BuildContext context, String aiResponse) {
  final theme = Theme.of(context);
  return Material(
    color: theme.scaffoldBackgroundColor,
    child: Container(
      width: shareCardWidth,
      padding: const EdgeInsets.all(_shareCardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.responseShareCardHeading,
            style: ThemeTextStyles.labelMedium(context).copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: _shareCardHeadingGap),
          Text(
            '"$aiResponse"',
            style: ThemeTextStyles.headlineSmall(context).copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: _shareCardBodyGap),
          Text(
            AppLocalizations.of(context)!.appName,
            style: ThemeTextStyles.bodySmall(context).copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ),
  );
}
