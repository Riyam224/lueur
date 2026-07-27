import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';

/// Mode toggle (Normal / Candidate) + Undo, the 1-9 digit pad + clear, and
/// the Auto Candidate Mode checkbox — mirrors the reference sudoku app's
/// control layout, themed to the app's own palette.
class SudokuNumberPadWidget extends StatelessWidget {
  final SudokuInputMode mode;
  final bool canUndo;
  final bool autoCandidateMode;
  final List<List<int>> values;
  final ValueChanged<SudokuInputMode> onModeChanged;
  final VoidCallback onUndo;
  final ValueChanged<int> onNumberTap;
  final VoidCallback onClearTap;
  final ValueChanged<bool> onAutoCandidateModeChanged;

  const SudokuNumberPadWidget({
    super.key,
    required this.mode,
    required this.canUndo,
    required this.autoCandidateMode,
    required this.values,
    required this.onModeChanged,
    required this.onUndo,
    required this.onNumberTap,
    required this.onClearTap,
    required this.onAutoCandidateModeChanged,
  });

  /// How many of each digit are still left to place — every digit fills
  /// exactly 9 cells in a solved grid, so 9 minus the placed count is what
  /// remains.
  List<int> _remainingCounts() {
    final placed = List.filled(SudokuBoardEntity.size + 1, 0);
    for (final row in values) {
      for (final value in row) {
        if (value != 0) placed[value]++;
      }
    }
    return [for (var n = 1; n <= SudokuBoardEntity.size; n++) 9 - placed[n]];
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final remaining = _remainingCounts();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ModeToggle(mode: mode, onChanged: onModeChanged),
            ),
            const SizedBox(width: 12),
            BouncyTap(
              onTap: canUndo ? onUndo : null,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: extra.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: extra.borderColor!),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.undo_rounded,
                  size: 20,
                  color: canUndo ? extra.primaryColor : extra.tertiaryTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var n = 1; n <= SudokuBoardEntity.size; n++)
              _NumberButton(
                number: n,
                remaining: remaining[n - 1],
                onTap: () => onNumberTap(n),
              ),
            BouncyTap(
              onTap: onClearTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: extra.cardBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: extra.borderColor!),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.close_rounded, size: 18, color: extra.secondaryTextColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BouncyTap(
          onTap: () => onAutoCandidateModeChanged(!autoCandidateMode),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: autoCandidateMode,
                onChanged: (value) => onAutoCandidateModeChanged(value ?? false),
                activeColor: extra.primaryColor,
              ),
              Text('Auto Candidate Mode', style: ThemeTextStyles.bodySmall(context)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final int remaining;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final isExhausted = remaining <= 0;

    return BouncyTap(
      onTap: isExhausted ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: extra.cardBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: extra.borderColor!),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isExhausted ? extra.tertiaryTextColor : extra.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$remaining',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: extra.tertiaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final SudokuInputMode mode;
  final ValueChanged<SudokuInputMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: extra.borderColor!),
      ),
      child: Row(
        children: [
          _segment(context, 'Normal', SudokuInputMode.normal),
          _segment(context, 'Candidate', SudokuInputMode.candidate),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, SudokuInputMode value) {
    final extra = context.extra;
    final isActive = mode == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isActive ? extra.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.whiteTextColor : extra.secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
