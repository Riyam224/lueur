import 'package:flutter/material.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';

/// Digit picker (1-4) + a clear button, used to fill the selected cell.
class SudokuNumberPadWidget extends StatelessWidget {
  final ValueChanged<int> onNumberTap;
  final VoidCallback onClearTap;

  const SudokuNumberPadWidget({
    super.key,
    required this.onNumberTap,
    required this.onClearTap,
  });

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var n = 1; n <= SudokuBoardEntity.size; n++)
          BouncyTap(
            onTap: () => onNumberTap(n),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: extra.cardBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: extra.borderColor!),
              ),
              alignment: Alignment.center,
              child: Text(
                '$n',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: extra.primaryColor,
                ),
              ),
            ),
          ),
        BouncyTap(
          onTap: onClearTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: extra.cardBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: extra.borderColor!),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.backspace_outlined, color: extra.secondaryTextColor),
          ),
        ),
      ],
    );
  }
}
