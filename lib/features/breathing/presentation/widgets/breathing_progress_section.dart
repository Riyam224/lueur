import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_cubit.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_state.dart';
import 'package:lueur/features/breathing/presentation/utils/breathing_time_format.dart';

/// Progress bar + elapsed/total time label. Scoped to `elapsedSeconds` so
/// the once-per-second tick only rebuilds this, not the ambient blobs,
/// ring, or Luna above.
class BreathingProgressSection extends StatelessWidget {
  const BreathingProgressSection({
    super.key,
    required this.totalSeconds,
    required this.inkColor,
  });

  final int totalSeconds;
  final Color inkColor;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BreathingCubit, BreathingState, int>(
      selector: (state) =>
          state is BreathingInProgress ? state.elapsedSeconds : 0,
      builder: (context, elapsedSeconds) {
        final progress = (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);

        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            SizedBox(height: AppSpacing.spaceSm),
            Text(
              '${formatBreathingTime(elapsedSeconds)} / '
              '${formatBreathingTime(totalSeconds)}',
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: inkColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}
