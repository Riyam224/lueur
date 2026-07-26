import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';

/// Renders the 4x4 grid, with a thicker border around each 2x2 box.
class SudokuGridWidget extends StatelessWidget {
  final SudokuState state;
  final void Function(int row, int col) onCellTap;

  const SudokuGridWidget({
    super.key,
    required this.state,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    const size = SudokuBoardEntity.size;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: extra.primaryColor!, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(size, (row) {
            return Expanded(
              child: Row(
                children: List.generate(size, (col) {
                  return Expanded(
                    child: _SudokuCell(
                      value: state.values[row][col],
                      isGiven: state.given[row][col],
                      isSelected:
                          state.selectedRow == row && state.selectedCol == col,
                      hasConflict: state.conflicts[row][col],
                      showRightBorder: col == 1,
                      showBottomBorder: row == 1,
                      onTap: () => onCellTap(row, col),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SudokuCell extends StatelessWidget {
  final int value;
  final bool isGiven;
  final bool isSelected;
  final bool hasConflict;
  final bool showRightBorder;
  final bool showBottomBorder;
  final VoidCallback onTap;

  const _SudokuCell({
    required this.value,
    required this.isGiven,
    required this.isSelected,
    required this.hasConflict,
    required this.showRightBorder,
    required this.showBottomBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final borderColor = extra.borderColor ?? AppColors.cardBorder;

    Color background;
    if (hasConflict) {
      background = AppColors.errorColor.withValues(alpha: 0.18);
    } else if (isSelected) {
      background = extra.primaryColor!.withValues(alpha: 0.22);
    } else if (isGiven) {
      background = extra.primaryColor!.withValues(alpha: 0.08);
    } else {
      background = Colors.transparent;
    }

    return BouncyTap(
      onTap: isGiven ? null : onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: background,
          border: Border(
            right: BorderSide(
              color: borderColor,
              width: showRightBorder ? 2.5 : 0.5,
            ),
            bottom: BorderSide(
              color: borderColor,
              width: showBottomBorder ? 2.5 : 0.5,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value == 0 ? '' : '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: isGiven ? FontWeight.w700 : FontWeight.w500,
            color: hasConflict
                ? AppColors.errorColor
                : (isGiven ? extra.primaryTextColor : extra.primaryColor),
          ),
        ),
      ),
    );
  }
}
