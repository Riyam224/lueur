import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';

/// Renders the 9x9 grid with a thicker border per 3x3 box, plus row/column/
/// box peer and same-digit highlighting — the classic "related cells" cues.
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
    const box = SudokuBoardEntity.boxSize;

    final selectedRow = state.selectedRow;
    final selectedCol = state.selectedCol;
    final selectedValue = (selectedRow != null && selectedCol != null)
        ? state.values[selectedRow][selectedCol]
        : 0;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: extra.primaryColor!, width: 2.5.w),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(size, (row) {
            return Expanded(
              child: Row(
                children: List.generate(size, (col) {
                  final isSelected = row == selectedRow && col == selectedCol;
                  final isPeer = !isSelected &&
                      selectedRow != null &&
                      selectedCol != null &&
                      (row == selectedRow ||
                          col == selectedCol ||
                          (row ~/ box == selectedRow ~/ box &&
                              col ~/ box == selectedCol ~/ box));
                  final isSameValue = !isSelected &&
                      selectedValue != 0 &&
                      state.values[row][col] == selectedValue;

                  return Expanded(
                    child: _SudokuCell(
                      value: state.values[row][col],
                      candidates: state.candidates[row][col],
                      isGiven: state.given[row][col],
                      isSelected: isSelected,
                      isPeer: isPeer,
                      isSameValue: isSameValue,
                      hasConflict: state.conflicts[row][col],
                      showRightBorder: (col + 1) % box == 0 && col != size - 1,
                      showBottomBorder: (row + 1) % box == 0 && row != size - 1,
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
  final Set<int> candidates;
  final bool isGiven;
  final bool isSelected;
  final bool isPeer;
  final bool isSameValue;
  final bool hasConflict;
  final bool showRightBorder;
  final bool showBottomBorder;
  final VoidCallback onTap;

  const _SudokuCell({
    required this.value,
    required this.candidates,
    required this.isGiven,
    required this.isSelected,
    required this.isPeer,
    required this.isSameValue,
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
      background = extra.primaryColor!.withValues(alpha: 0.30);
    } else if (isSameValue) {
      background = extra.primaryColor!.withValues(alpha: 0.18);
    } else if (isPeer) {
      background = extra.primaryColor!.withValues(alpha: 0.08);
    } else if (isGiven) {
      background = extra.primaryColor!.withValues(alpha: 0.04);
    } else {
      background = AppColors.transparent;
    }

    return BouncyTap(
      onTap: isGiven ? null : onTap,
      pressedScale: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: background,
          border: Border(
            right: BorderSide(
              color: borderColor,
              width: showRightBorder ? 2.0 : 0.5,
            ),
            bottom: BorderSide(
              color: borderColor,
              width: showBottomBorder ? 2.0 : 0.5,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: value != 0
            ? Text(
                '$value',
                style: ThemeTextStyles.titleLarge(context).copyWith(
                  fontWeight: isGiven ? FontWeight.w700 : FontWeight.w500,
                  color: hasConflict
                      ? AppColors.errorColor
                      : (isGiven ? extra.primaryTextColor : extra.primaryColor),
                ),
              )
            : candidates.isEmpty
                ? null
                : _CandidateGrid(candidates: candidates, color: extra.secondaryTextColor!),
      ),
    );
  }
}

class _CandidateGrid extends StatelessWidget {
  final Set<int> candidates;
  final Color color;

  const _CandidateGrid({required this.candidates, required this.color});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(2.r),
      children: List.generate(9, (i) {
        final n = i + 1;
        return Center(
          child: candidates.contains(n)
              ? Text(
                  '$n',
                  style: ThemeTextStyles.captionSmall(
                    context,
                  ).copyWith(fontSize: 8.sp, color: color),
                )
              : null,
        );
      }),
    );
  }
}
