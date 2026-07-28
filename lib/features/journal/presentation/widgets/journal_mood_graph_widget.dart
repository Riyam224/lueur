import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Collapsible bar chart showing how many journal entries per day this week.
class JournalMoodGraphWidget extends StatefulWidget {
  const JournalMoodGraphWidget({super.key, required this.entries});

  final List<MoodEntryEntity> entries;

  @override
  State<JournalMoodGraphWidget> createState() => _JournalMoodGraphWidgetState();
}

class _JournalMoodGraphWidgetState extends State<JournalMoodGraphWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _animController;
  late final Animation<double> _expandAnim;
  late List<int> _counts;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _counts = _countsThisWeek();
  }

  @override
  void didUpdateWidget(covariant JournalMoodGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.entries, widget.entries)) {
      _counts = _countsThisWeek();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_expanded) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
    setState(() => _expanded = !_expanded);
  }

  /// Build a count-per-weekday map for the current ISO week.
  List<int> _countsThisWeek() {
    final now = DateTime.now();
    // Start of the current ISO week (Monday)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final counts = List<int>.filled(7, 0);
    for (final e in widget.entries) {
      if (e.createdAt.isAfter(weekStart) && e.createdAt.isBefore(weekEnd)) {
        final dayIndex = e.createdAt.weekday - 1; // 0=Mon … 6=Sun
        counts[dayIndex]++;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counts = _counts;
    final maxY = (counts.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // ── Header / toggle ────────────────────────────────────
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.spaceLg,
                AppSpacing.spaceMd,
                AppSpacing.spaceMd,
                AppSpacing.spaceMd,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.commonThisWeekLabel,
                      style: ThemeTextStyles.labelMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Chart (animated height) ────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.spaceMd,
                0,
                AppSpacing.spaceLg,
                AppSpacing.spaceLg,
              ),
              child: SizedBox(
                height: 140.h,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    minY: 0,
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(

                      ),
                      rightTitles: const AxisTitles(

                      ),
                      topTitles: const AxisTitles(

                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= _days.length) {
                              return const SizedBox.shrink();
                            }
                            final isToday =
                                i == DateTime.now().weekday - 1;
                            return Padding(
                              padding: EdgeInsets.only(top: AppSpacing.spaceXs),
                              child: Text(
                                _days[i],
                                style: ThemeTextStyles.labelSmall(context)
                                    .copyWith(
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isToday
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightSecondaryText),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(7, (i) {
                      final isToday = i == DateTime.now().weekday - 1;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: counts[i].toDouble(),
                            width: 18.w,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(6.r),
                            ),
                            color: isToday
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ],
                      );
                    }),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => isDark
                            ? AppColors.darkBackground
                            : AppColors.lightSurface,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final count = rod.toY.toInt();
                          return BarTooltipItem(
                            '$count ${count == 1 ? 'entry' : 'entries'}',
                            ThemeTextStyles.labelSmall(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
