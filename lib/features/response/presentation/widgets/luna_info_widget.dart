import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/utils/app_strings.dart';

/// Luna information widget showing name and subtitle
class LunaInfoWidget extends StatelessWidget {
  const LunaInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.lunaName,
          style: ThemeTextStyles.titleLarge(context),
        ),
        SizedBox(height: AppSpacing.spaceXs),
        Text(
          AppStrings.lunaSubtitle,
          style: ThemeTextStyles.bodySmall(context),
        ),
      ],
    );
  }
}
