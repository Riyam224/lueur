import 'package:flutter/material.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Back / help / new-game row at the top of the sudoku screen.
class SudokuToolbar extends StatelessWidget {
  const SudokuToolbar({
    super.key,
    required this.onLeave,
    required this.onHelp,
    required this.onNewGame,
  });

  final VoidCallback onLeave;
  final VoidCallback onHelp;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onLeave,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const Spacer(),
        IconButton(
          onPressed: onHelp,
          icon: const Icon(Icons.help_outline_rounded),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz_rounded),
          onSelected: (_) => onNewGame(),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'new',
              child: Text(AppLocalizations.of(context)!.sudokuNewGameMenuItem),
            ),
          ],
        ),
      ],
    );
  }
}
