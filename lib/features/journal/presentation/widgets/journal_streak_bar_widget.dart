import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/plant/domain/entities/plant_stage.dart';

/// A 7-day activity strip, plus the current streak count pulled from
/// [PlantCubit]/[StreakRepository] — this widget never recomputes the
/// streak itself, it only visualizes which of the last 7 days had entries.
class JournalStreakBarWidget extends StatelessWidget {
  static const double _minBarHeight = 12;
  static const double _maxBarHeight = 44;

  final List<MoodEntryEntity> entries;
  final int streakDays;

  const JournalStreakBarWidget({
    super.key,
    required this.entries,
    required this.streakDays,
  });

  Map<DateTime, int> _countsByDay() {
    final counts = <DateTime, int>{};
    for (final entry in entries) {
      final localCreatedAt = entry.createdAt.toLocal();
      final day = DateTime(
        localCreatedAt.year,
        localCreatedAt.month,
        localCreatedAt.day,
      );
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final counts = _countsByDay();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final days = List.generate(
      7,
      (i) => todayDate.subtract(Duration(days: 6 - i)),
    );
    final maxCount = counts.values.isEmpty
        ? 1
        : counts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (extra.shadowColor ?? Colors.black).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                streakDays == 1 ? '1 day streak' : '$streakDays day streak',
                style: ThemeTextStyles.titleMedium(context),
              ),
              // Same growth-stage plant as the home screen — grown from the
              // same streak count passed into this widget, so it's always
              // in sync with what "$streakDays day streak" says above.
              Lottie.asset(
                PlantStage.fromStreak(streakDays).lottiePath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(width: 40, height: 40),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((day) {
              final isToday = day == todayDate;
              final count = counts[day] ?? 0;
              final ratio = count / maxCount;
              final height =
                  _minBarHeight + ratio * (_maxBarHeight - _minBarHeight);
              final barColor = count > 0
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.15);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 16,
                    child: isToday
                        ? const Text('🌱', style: TextStyle(fontSize: 14))
                        : null,
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 16,
                    height: height,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('E').format(day).substring(0, 1),
                    style: ThemeTextStyles.captionSmall(context),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
