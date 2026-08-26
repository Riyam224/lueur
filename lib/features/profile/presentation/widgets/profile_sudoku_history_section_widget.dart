import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Results aren't replayable, so there's no reopen action — just delete.
class ProfileSudokuHistorySectionWidget extends StatelessWidget {
  const ProfileSudokuHistorySectionWidget({super.key});

  static String _relativeDate(BuildContext context, DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return AppLocalizations.of(context)!.profileSudokuRelativeToday;
    if (days == 1) return AppLocalizations.of(context)!.profileSudokuRelativeYesterday;
    return AppLocalizations.of(context)!.profileSudokuRelativeDaysAgo(days);
  }

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuResultsCubit, SudokuResultsState>(
      builder: (context, state) {
        if (state is SudokuResultsError) {
          return _emptyCard(
            context,
            AppLocalizations.of(context)!.profileSudokuHistoryErrorSubtitle,
          );
        }
        if (state is! SudokuResultsLoaded) return const SizedBox.shrink();

        if (state.results.isEmpty) {
          return _emptyCard(
            context,
            AppLocalizations.of(context)!.profileSudokuHistoryEmptySubtitle,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.profileSudokuHistoryTitle, style: ThemeTextStyles.headlineSmall(context)),
            SizedBox(height: AppSpacing.spaceSm),
            ...state.results.take(5).map(
              (result) => Dismissible(
                key: ValueKey(result.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) =>
                    context.read<SudokuResultsCubit>().deleteResult(result.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: AppSpacing.spaceXl),
                  margin: EdgeInsets.only(bottom: AppSpacing.spaceMd),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.whiteTextColor,
                  ),
                ),
                child: _ResultRow(
                  result: result,
                  dateLabel: _relativeDate(context, result.completedAt),
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
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(
          color: context.extra.borderColor ?? Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text('🧩', style: TextStyle(fontSize: AppSizes.iconLg)),
          SizedBox(height: AppSpacing.spaceSm),
          Text(AppLocalizations.of(context)!.profileSudokuHistoryTitle, style: ThemeTextStyles.titleMedium(context)),
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
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
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
                  result.won
                      ? AppLocalizations.of(context)!.profileSudokuSolvedIt
                      : AppLocalizations.of(context)!.profileSudokuGaveItAGo,
                  style: ThemeTextStyles.bodyMedium(context),
                ),
                Text(
                  result.won
                      ? '${ProfileSudokuHistorySectionWidget._formatDuration(result.durationSeconds)} · $dateLabel'
                      : '${AppLocalizations.of(context)!.profileSudokuMistakesCount(result.mistakes)} · $dateLabel',
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
