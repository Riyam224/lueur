import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';

/// "── or ──" divider between the primary CTA and social sign-in.
class AuthOrDivider extends StatelessWidget {
  final Color lineColor;
  final Color textColor;

  const AuthOrDivider({
    super.key,
    required this.lineColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: AuthConstants.dividerThickness,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingSm,
          ),
          child: Text(
            AppStrings.authOrDivider,
            style: AppTextStyles.captionSmall(context)
                .copyWith(color: textColor),
          ),
        ),
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: AuthConstants.dividerThickness,
          ),
        ),
      ],
    );
  }
}
