import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_state.dart';

/// "Sudoku History" — past game results (win/lose), swipe to delete. No
/// reopen: results aren't replayable, just a record of how it went.
class ProfileSudokuHistorySectionWidget extends StatelessWidget {
  const ProfileSudokuHistorySectionWidget({super.key});

  static String _relativeDate(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuResultsCubit, SudokuResultsState>(
      builder: (context, state) {
        if (state is SudokuResultsError) {
          return _emptyCard(
            context,
            'Couldn\'t load your Sudoku history — pull to refresh and try again',
          );
        }
        if (state is! SudokuResultsLoaded) return const SizedBox.shrink();

        if (state.results.isEmpty) {
          return _emptyCard(
            context,
            'Play a round of Sudoku to see your results here',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sudoku History', style: ThemeTextStyles.headlineSmall(context)),
            SizedBox(height: AppSpacing.spaceSm),
            ...state.results.take(5).map(
              (result) => Dismissible(
                key: ValueKey(result.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) =>
                    context.read<SudokuResultsCubit>().deleteResult(result.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: EdgeInsets.only(bottom: AppSpacing.spaceMd),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.whiteTextColor,
                  ),
                ),
                child: _ResultRow(
                  result: result,
                  dateLabel: _relativeDate(result.completedAt),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyCard(BuildContext context, String subtitle) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.extra.borderColor ?? Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          const Text('🧩', style: TextStyle(fontSize: 32)),
          SizedBox(height: AppSpacing.spaceSm),
          Text('Sudoku History', style: ThemeTextStyles.titleMedium(context)),
          SizedBox(height: AppSpacing.spaceXs),
          Text(
            subtitle,
            style: ThemeTextStyles.bodySmall(context)
                .copyWith(color: context.extra.secondaryTextColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final SudokuResultEntity result;
  final String dateLabel;

  const _ResultRow({required this.result, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.spaceMd),
      padding: EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: extra.borderColor ?? Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            result.won ? Icons.emoji_events_rounded : Icons.replay_rounded,
            color: result.won ? AppColors.buttermilkYellow : extra.secondaryTextColor,
          ),
          SizedBox(width: AppSpacing.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.won ? 'Solved it' : 'Gave it a go',
                  style: ThemeTextStyles.bodyMedium(context),
                ),
                Text(
                  '${result.mistakes} mistake${result.mistakes == 1 ? '' : 's'} · $dateLabel',
                  style: ThemeTextStyles.bodySmall(context)
                      .copyWith(color: extra.secondaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
