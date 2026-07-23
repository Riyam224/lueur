import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/features/plant/domain/entities/streak_growth_stage.dart';

/// Renders the plant Lottie animation for the current point in the
/// repeating 7-day streak growth cycle (seed → sprout → plant → bloom).
class StreakGrowthWidget extends StatelessWidget {
  const StreakGrowthWidget({
    required this.streakDays,
    this.size = 110,
    super.key,
  });

  final int streakDays;
  final double size;

  @override
  Widget build(BuildContext context) {
    final stage = StreakGrowthStage.fromStreak(streakDays);
    return Lottie.asset(
      stage.lottiePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      repeat: true,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }
}
