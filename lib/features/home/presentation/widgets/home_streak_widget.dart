import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/plant/domain/entities/streak_milestone.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Compact, single-line nudge toward the next streak milestone (7/10/15/30
/// days). Sits directly below [GreetingCard], which already shows the
/// current streak count and plant animation — this only adds the one thing
/// not shown there: how close the next milestone is. Renders nothing when
/// there's no streak in progress or every milestone has already been
/// reached, rather than forcing a line with nothing meaningful to say.
class HomeStreakWidget extends StatelessWidget {
  const HomeStreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlantCubit, PlantState>(
      builder: (context, state) {
        if (state is! PlantLoaded || state.streakDays <= 0) {
          return const SizedBox.shrink();
        }
        final next = StreakMilestone.next(state.streakDays);
        if (next == null) return const SizedBox.shrink();

        final daysLeft = next.days - state.streakDays;
        final extra = context.extra;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceLg,
              vertical: AppSpacing.spaceSm,
            ),
            decoration: BoxDecoration(
              color: extra.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
              border: Border.all(
                color: extra.borderColor ?? AppColors.cardBorder,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!
                  .homeNextMilestoneHint(daysLeft, next.days),
              textAlign: TextAlign.center,
              style: ThemeTextStyles.bodySmall(context)
                  .copyWith(color: extra.secondaryTextColor),
            ),
          ),
        );
      },
    );
  }
}
