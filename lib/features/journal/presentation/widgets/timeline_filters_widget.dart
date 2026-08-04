import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_filter_chip.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Search field + horizontally scrolling mood/month filter chip rows for
/// the timeline screen.
class TimelineFiltersWidget extends StatelessWidget {
  const TimelineFiltersWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.entries,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<MoodEntryEntity> entries;
  final MoodType? selectedMood;
  final ValueChanged<MoodType?> onMoodSelected;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime?> onMonthSelected;

  List<MoodType> _moodsPresent() {
    final moods = <MoodType>{};
    for (final entry in entries) {
      final moodType = moodTypeFromEmoji(entry.emoji);
      if (moodType != null) moods.add(moodType);
    }
    return MoodType.values.where(moods.contains).toList();
  }

  List<DateTime> _monthsPresent() {
    final months = <DateTime>{};
    for (final entry in entries) {
      months.add(DateTime(entry.createdAt.year, entry.createdAt.month));
    }
    return months.toList()..sort((a, b) => b.compareTo(a));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: ThemeTextStyles.bodyMedium(context),
          decoration: InputDecoration(
            hintText: l10n.journalSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: context.extra.cardBackgroundColor,
            contentPadding: EdgeInsets.symmetric(
              vertical: AppSpacing.spaceSm,
              horizontal: AppSpacing.spaceMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.spaceMd),
        SizedBox(
          height: 36.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              TimelineFilterChip(
                label: l10n.timelineFilterAllMoods,
                selected: selectedMood == null,
                onTap: () => onMoodSelected(null),
              ),
              for (final mood in _moodsPresent())
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.spaceSm),
                  child: TimelineFilterChip(
                    label: '${mood.emoji} ${mood.label(context)}',
                    selected: selectedMood == mood,
                    onTap: () => onMoodSelected(
                      selectedMood == mood ? null : mood,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.spaceSm),
        SizedBox(
          height: 36.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              TimelineFilterChip(
                label: l10n.timelineFilterAllMonths,
                selected: selectedMonth == null,
                onTap: () => onMonthSelected(null),
              ),
              for (final month in _monthsPresent())
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.spaceSm),
                  child: TimelineFilterChip(
                    label: DateFormat('MMM yyyy', locale).format(month),
                    selected: selectedMonth == month,
                    onTap: () => onMonthSelected(
                      selectedMonth == month ? null : month,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
