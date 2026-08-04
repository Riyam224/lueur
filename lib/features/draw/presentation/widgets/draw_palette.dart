import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_state.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_color_swatch.dart';

/// The fixed brush-color palette shown below the canvas.
class DrawPalette extends StatelessWidget {
  const DrawPalette({super.key});

  static const List<Color> palette = [
    AppColors.breathingGradientLavender,
    AppColors.lavenderLilac,
    AppColors.darkMintTeal,
    AppColors.breathingGradientPeach,
    AppColors.darkSunsetPeach,
    AppColors.buttermilkYellow,
    AppColors.darkGoldenYellow,
    AppColors.darkSkyBlue,
    AppColors.darkCoralPink,
    AppColors.lightOnBackground,
  ];

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final ringColor = extra.primaryTextColor ?? AppColors.primaryTextColor;

    return BlocBuilder<DrawCubit, DrawState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingLg,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.spaceSm,
            runSpacing: AppSpacing.spaceSm,
            children: [
              for (final color in palette)
                DrawColorSwatch(
                  color: color,
                  isSelected: state.currentColor == color,
                  ringColor: ringColor,
                  onTap: () => context.read<DrawCubit>().selectColor(color),
                ),
            ],
          ),
        );
      },
    );
  }
}
