import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Win/loss message + "done"/"play again" actions shown once a sudoku game
/// ends. Shared by both outcomes since only the copy and primary action
/// differ.
class SudokuResultBanner extends StatelessWidget {
  const SudokuResultBanner({
    super.key,
    required this.message,
    required this.doneLabel,
    required this.primaryLabel,
    required this.onDone,
    required this.onPrimary,
  });

  final String message;
  final String doneLabel;
  final String primaryLabel;
  final VoidCallback onDone;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.space2Xl),
        Text(
          message,
          style: ThemeTextStyles.titleMedium(context),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.spaceMd),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDone,
                child: Text(doneLabel),
              ),
            ),
            SizedBox(width: AppSpacing.spaceMd),
            Expanded(
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButtonFill,
                  foregroundColor: AppColors.whiteTextColor,
                ),
                child: Text(primaryLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
