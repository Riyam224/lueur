import 'package:flutter/material.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// "Talk to Luna" text link shown below the drawing palette.
class DrawTalkToLunaLink extends StatelessWidget {
  const DrawTalkToLunaLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondaryText = context.extra.secondaryTextColor;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: secondaryText),
      child: Text(
        AppLocalizations.of(context)!.drawTalkToLunaLink,
        style: ThemeTextStyles.bodySmall(context).copyWith(
          color: secondaryText,
        ),
      ),
    );
  }
}
