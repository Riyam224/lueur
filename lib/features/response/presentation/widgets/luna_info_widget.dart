import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

class LunaInfoWidget extends StatelessWidget {
  const LunaInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.lunaName,
          style: ThemeTextStyles.titleLarge(context),
        ),
        SizedBox(height: AppSpacing.spaceXs),
        Text(
          AppLocalizations.of(context)!.lunaSubtitle,
          style: ThemeTextStyles.bodySmall(context),
        ),
      ],
    );
  }
}
