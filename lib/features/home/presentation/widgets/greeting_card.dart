import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur_app/core/constants/app_sizes.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/features/plant/domain/entities/plant_stage.dart';
import 'package:lueur_app/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur_app/features/plant/presentation/cubit/plant_state.dart';

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

  String _lunaMessage(String name, int hour, int streak, bool hasEntries) {
    if (!hasEntries) {
      return 'Hey $name, I\'m Luna. I\'m here whenever you\'re ready to talk 🌱';
    }
    if (hour >= 5 && hour < 12) {
      if (streak > 0) return 'Good morning, $name! $streak-day streak — that\'s beautiful 🌸';
      return 'Good morning, $name ☀️ What\'s on your heart today?';
    }
    if (hour >= 12 && hour < 17) {
      return 'Hey $name 🌤️ How\'s your day going so far?';
    }
    if (hour >= 17 && hour < 21) {
      if (streak > 0) return 'Good evening, $name 🌙 $streak days strong — I\'m proud of you.';
      return 'Good evening, $name 🌙 I\'m here if you want to talk.';
    }
    return 'Hey $name ⭐ Still up? I\'m listening.';
  }

  String _timeBasedLottiePath(int hour) {
    if (hour >= 5 && hour < 12) return 'assets/lottie/seed_soil.json';
    if (hour >= 12 && hour < 17) return 'assets/lottie/plant_sprout.json';
    if (hour >= 17 && hour < 21) return 'assets/lottie/plant.json';
    return 'assets/lottie/blooming.json';
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
      child: BlocBuilder<PlantCubit, PlantState>(
        builder: (context, state) {
          final extra = context.extra;
          final onPrimary = extra.onPrimaryTextColor!;
          final primary = extra.primaryColor!;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final stage = state is PlantLoaded ? state.stage : PlantStage.seed;
          final streak = state is PlantLoaded ? state.streakDays : 0;

          _lastStage ??= stage;

          final message = _lunaMessage(widget.userName, hour, streak, widget.hasEntries);
          final lottiePath = _timeBasedLottiePath(hour);

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.primaryDark, AppColors.primaryDarkDeep]
                    : [AppColors.primary, AppColors.primaryContainer],
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
                        style: TextStyle(
                          color: onPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          fontFamilyFallback: const [
                            'Apple Color Emoji',
                            'Noto Color Emoji',
                          ],
                        ),
                      ),
                      if (streak > 0) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: onPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$streak day${streak == 1 ? '' : 's'} streak',
                                style: TextStyle(
                                  color: onPrimary,
                                  fontSize: 12,
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
                Lottie.asset(
                  lottiePath,
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 110, height: 110),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
