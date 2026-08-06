import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/plant/domain/entities/plant_stage.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';
import 'package:lueur/features/plant/presentation/widgets/streak_growth_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Greeting card displaying Luna's contextual message with dynamic plant animation.
class GreetingCard extends StatefulWidget {
  const GreetingCard({
    required this.userName,
    required this.hasEntries,
    super.key,
  });

  final String userName;
  final bool hasEntries;

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  PlantStage? _lastStage;

  String _lunaMessage(
    BuildContext context,
    String name,
    int hour,
    int streak,
    bool hasEntries,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (!hasEntries) {
      return l10n.homeGreetingNoEntries(name);
    }
    if (hour >= 5 && hour < 12) {
      if (streak > 0) {
        return l10n.homeGreetingMorningStreak(name, streak);
      }
      return l10n.homeGreetingMorning(name);
    }
    if (hour >= 12 && hour < 17) {
      return l10n.homeGreetingAfternoon(name);
    }
    if (hour >= 17 && hour < 21) {
      if (streak > 0) {
        return l10n.homeGreetingMessage(name, streak);
      }
      return l10n.homeGreetingEveningNoStreak(name);
    }
    return l10n.homeGreetingLateNight(name);
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    return BlocListener<PlantCubit, PlantState>(
      listenWhen: (previous, current) {
        if (current is! PlantLoaded) return false;
        if (_lastStage == null) return true;
        return current.stage.index > _lastStage!.index;
      },
      listener: (context, state) {
        if (state is PlantLoaded && _lastStage != null) {
          HapticFeedback.heavyImpact();
        }
        if (state is PlantLoaded) {
          _lastStage = state.stage;
        }
      },
      child: BlocSelector<PlantCubit, PlantState, (PlantStage, int)>(
        selector: (state) => state is PlantLoaded
            ? (state.stage, state.streakDays)
            : (PlantStage.seed, 0),
        builder: (context, plant) {
          final extra = context.extra;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final onPrimary = extra.onPrimaryTextColor!;
          final primary = extra.primaryColor!;
          final (stage, streak) = plant;

          _lastStage ??= stage;

          final message = _lunaMessage(
            context,
            widget.userName,
            hour,
            streak,
            widget.hasEntries,
          );

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.pastelOrchid, AppColors.primaryDarkDeep]
                    : [
                        AppColors.greetingGradientStart,
                        AppColors.greetingGradientEnd,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: ThemeTextStyles.editorialHeadline(
                          context,
                          fontSize: 19.sp,
                          color: onPrimary,
                        ),
                      ),
                      if (streak > 0) ...[
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: onPrimary.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppSizes.borderRadiusLg),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: onPrimary,
                                size: 14.sp,
                              ),
                              SizedBox(width: AppSpacing.spaceXs),
                              Text(
                                AppLocalizations.of(context)!
                                    .homeDaysStreakChip(streak),
                                style: ThemeTextStyles.labelSmall(context)
                                    .copyWith(
                                  color: onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                StreakGrowthWidget(streakDays: streak),
              ],
            ),
          );
        },
      ),
    );
  }
}
