import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Mode toggle + Undo, the 1-9 digit pad + clear, and the Auto Candidate
/// checkbox — mirrors the reference sudoku app's control layout.
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

  /// How many of each digit are still left to place — every digit fills 9
  /// cells in a solved grid, so 9 minus the placed count remains.
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
            SizedBox(width: AppSpacing.spaceMd),
            BouncyTap(
              onTap: canUndo ? onUndo : null,
              child: Container(
                height: AppSizes.buttonHeightSm,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPaddingMd,
                ),
                decoration: BoxDecoration(
                  color: extra.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                  border: Border.all(color: extra.borderColor!),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.undo_rounded,
                  size: AppSizes.iconSm,
                  color: canUndo ? extra.primaryColor : extra.tertiaryTextColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sectionSpacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var n = 1; n <= 5; n++)
              _NumberButton(
                number: n,
                remaining: remaining[n - 1],
                onTap: () => onNumberTap(n),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.verticalPaddingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var n = 6; n <= SudokuBoardEntity.size; n++)
              _NumberButton(
                number: n,
                remaining: remaining[n - 1],
                onTap: () => onNumberTap(n),
              ),
            BouncyTap(
              onTap: onClearTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: extra.cardBackgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: extra.borderColor!),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: extra.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Opacity(
                    opacity: 0,
                    child: Text(
                      '0',
                      style: ThemeTextStyles.captionSmall(
                        context,
                      ).copyWith(fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.verticalPaddingSm),
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
              Text(
                AppLocalizations.of(context)!.sudokuAutoCandidateModeLabel,
                style: ThemeTextStyles.bodySmall(context),
              ),
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
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: extra.cardBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: extra.borderColor!),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: ThemeTextStyles.titleMedium(context).copyWith(
                fontWeight: FontWeight.w700,
                color: isExhausted ? extra.tertiaryTextColor : extra.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '$remaining',
            style: ThemeTextStyles.captionSmall(context).copyWith(
              fontSize: 10.sp,
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
      height: AppSizes.buttonHeightSm,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(color: extra.borderColor!),
      ),
      child: Row(
        children: [
          _segment(
            context,
            AppLocalizations.of(context)!.sudokuNormalModeLabel,
            SudokuInputMode.normal,
          ),
          _segment(
            context,
            AppLocalizations.of(context)!.sudokuCandidateModeLabel,
            SudokuInputMode.candidate,
          ),
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
            color: isActive ? extra.primaryColor : AppColors.transparent,
            borderRadius: BorderRadius.circular(17.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: ThemeTextStyles.labelSmall(context).copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.whiteTextColor : extra.secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
