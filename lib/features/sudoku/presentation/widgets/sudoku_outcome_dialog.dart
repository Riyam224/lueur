import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Which end-of-round outcome [SudokuOutcomeDialog] is showing — controls
/// copy and the secondary action's label, everything else is shared.
enum SudokuOutcomeVariant { fail, success }

/// Shown once a round ends (won, or 3 mistakes) — replaces the old inline
/// result banner with a centered, explicit-choice dialog. Doesn't dismiss on
/// tap-outside: the player picks a fresh board or steps away on purpose.
Future<void> showSudokuOutcomeDialog(
  BuildContext context, {
  required SudokuOutcomeVariant variant,
}) {
  // showGeneralDialog pushes on the root navigator, which sits outside the
  // route-scoped BlocProvider<SudokuCubit> — so the cubit must be captured
  // here (this context is still a descendant of it) and re-provided into
  // the dialog's own subtree, or context.read<SudokuCubit>() inside the
  // dialog throws ProviderNotFoundException.
  final sudokuCubit = context.read<SudokuCubit>();
  return showGeneralDialog(
    context: context,
    barrierLabel: AppLocalizations.of(context)!.commonDismissBarrierLabel,
    barrierColor: AppColors.overlayBlack.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    pageBuilder: (dialogContext, _, __) => BlocProvider.value(
      value: sudokuCubit,
      child: SudokuOutcomeDialog(variant: variant),
    ),
  );
}

/// Custom centered dialog for both the "solved it" and "out of tries"
/// outcomes — same shape (rounded card, soft shadow, orange primary CTA),
/// only the message and secondary action differ by [variant].
class SudokuOutcomeDialog extends StatelessWidget {
  const SudokuOutcomeDialog({super.key, required this.variant});

  final SudokuOutcomeVariant variant;

  void _startNewGame(BuildContext context) {
    Navigator.of(context).pop();
    context.read<SudokuCubit>().start();
  }

  void _exit(BuildContext context) {
    Navigator.of(context).pop();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extra = context.extra;
    final isSuccess = variant == SudokuOutcomeVariant.success;

    return Center(
      child: Material(
        color: AppColors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingXl,
          ),
          padding: EdgeInsets.all(AppSpacing.space2Xl),
          decoration: BoxDecoration(
            color: extra.cardBackgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusXl),
            boxShadow: [
              BoxShadow(
                color: (extra.shadowColor ?? AppColors.overlayBlack)
                    .withValues(alpha: 0.15),
                blurRadius: 32.r,
                offset: Offset(0, 12.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSuccess
                    ? l10n.sudokuOutcomeSuccessMessage
                    : l10n.sudokuOutcomeFailMessage,
                textAlign: TextAlign.center,
                style: ThemeTextStyles.titleMedium(context),
              ),
              BlocBuilder<SudokuCubit, SudokuState>(
                buildWhen: (previous, current) =>
                    previous.resultSaveFailed != current.resultSaveFailed,
                builder: (context, state) {
                  if (!state.resultSaveFailed) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: AppSpacing.spaceSm),
                    child: Text(
                      l10n.sudokuResultSaveFailedNotice,
                      textAlign: TextAlign.center,
                      style: ThemeTextStyles.captionSmall(context).copyWith(
                        color: extra.secondaryTextColor,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.spaceXl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _exit(context),
                      child: Text(
                        isSuccess
                            ? l10n.sudokuDoneButton
                            : l10n.sudokuOutcomeBackButton,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.spaceMd),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startNewGame(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButtonFill,
                        foregroundColor: AppColors.whiteTextColor,
                      ),
                      child: Text(l10n.sudokuOutcomeNewGameButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
