import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Error icon + message + retry button shown when generating the AI
/// response fails.
class ResponseErrorState extends StatelessWidget {
  const ResponseErrorState({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
              size: AppSizes.iconXl,
            ),
            SizedBox(height: AppSpacing.spaceMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.bodyMedium(context),
            ),
            SizedBox(height: AppSpacing.spaceLg),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
