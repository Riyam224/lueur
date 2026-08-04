import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_state.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_painter.dart';

/// The drawable canvas surface — tracks pan gestures as strokes on
/// [DrawCubit].
class DrawCanvas extends StatelessWidget {
  const DrawCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingLg,
      ),
      child: BlocBuilder<DrawCubit, DrawState>(
        builder: (context, state) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: extra.cardBackgroundColor,
                border: Border.all(
                  color: extra.borderColor ?? AppColors.cardBorder,
                ),
              ),
              child: GestureDetector(
                onPanStart: (details) => context
                    .read<DrawCubit>()
                    .startStroke(details.localPosition),
                onPanUpdate: (details) => context
                    .read<DrawCubit>()
                    .extendStroke(details.localPosition),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DrawPainter(paths: state.paths),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
