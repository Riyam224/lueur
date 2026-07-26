import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_grid_widget.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_number_pad_widget.dart';

/// A calm, simple 4x4 sudoku — one of Luna's offerings for a rough moment.
class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<SudokuCubit, SudokuState>(
          listener: (context, state) {
            if (state.status == SudokuStatus.won) {
              _confettiController.play();
            }
          },
          builder: (context, state) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 24,
                  gravity: 0.3,
                  colors: const [
                    AppColors.primary,
                    AppColors.lavender,
                    AppColors.blushPink,
                    AppColors.primaryContainer,
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPaddingLg,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          Expanded(
                            child: Text(
                              'a small, calm puzzle',
                              style: ThemeTextStyles.headlineSmall(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        'mistakes: ${state.mistakes} / ${SudokuCubit.maxMistakes}',
                        style: ThemeTextStyles.bodySmall(context).copyWith(
                          color: context.extra.secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: AppSpacing.spaceXl),
                      SudokuGridWidget(
                        state: state,
                        onCellTap: (row, col) =>
                            context.read<SudokuCubit>().selectCell(row, col),
                      ),
                      SizedBox(height: AppSpacing.space2Xl),
                      SudokuNumberPadWidget(
                        onNumberTap: (n) =>
                            context.read<SudokuCubit>().inputNumber(n),
                        onClearTap: () =>
                            context.read<SudokuCubit>().clearSelectedCell(),
                      ),
                      if (state.status != SudokuStatus.playing) ...[
                        SizedBox(height: AppSpacing.space2Xl),
                        Text(
                          state.status == SudokuStatus.won
                              ? 'you solved it! 🌸'
                              : 'that\'s okay — want to try again?',
                          style: ThemeTextStyles.titleMedium(context),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.spaceMd),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.go(AppRoutes.home),
                                child: const Text('done'),
                              ),
                            ),
                            SizedBox(width: AppSpacing.spaceMd),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    context.read<SudokuCubit>().start(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryButtonFill,
                                  foregroundColor: AppColors.whiteTextColor,
                                ),
                                child: const Text('play again'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: AppSpacing.spaceXl),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
