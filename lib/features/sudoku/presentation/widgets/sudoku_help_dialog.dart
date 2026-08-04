import 'package:flutter/material.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// "How to play" dialog explaining sudoku rules.
void showSudokuHelpDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.sudokuHowToPlayTitle),
      content: Text(l10n.sudokuHowToPlayMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.sudokuGotIt),
        ),
      ],
    ),
  );
}
