import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// The full emotional timeline — every memory, searchable and filterable by
/// mood or month. Reached from Home's and Journal's "View full timeline"
/// links; Journal itself only teases the latest 3 entries.
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<JournalGridCubit>()..loadEntries()),
        // Standalone top-level route (sibling of the shell), so the shell's
        // MoodCubit provider isn't in scope here — re-attach the same
        // singleton, mirroring how the other standalone routes (chat,
        // response, weeklyLetter) do it.
        BlocProvider.value(value: sl<MoodCubit>()),
      ],
      child: BlocListener<MoodCubit, MoodState>(
        listenWhen: (previous, current) =>
            current is MoodHistorySuccess &&
            current.justGenerated != null &&
            (previous is! MoodHistorySuccess ||
                previous.justGenerated != current.justGenerated),
        listener: (context, state) {
          unawaited(context.read<JournalGridCubit>().loadEntries());
        },
        child: const _TimelineView(),
      ),
    );
  }
}

/// One journal bubble's worth of data — every entry from a single calendar
/// day, chronologically ordered. Color/pin/delete act on [representative]
/// (the day's most recent entry) since those fields live on a single entry.
class _DayGroup {
  final DateTime date;
  final List<MoodEntryEntity> entries;

  _DayGroup({required this.date, required this.entries});

  MoodEntryEntity get representative => entries.last;

  bool get pinned => entries.any((e) => e.pinned);

  Duration? get conversationDuration => entries.length > 1
      ? entries.last.createdAt.difference(entries.first.createdAt)
      : null;
}

/// A month's worth of day-groups, newest day first.
class _MonthSection {
  final DateTime month;
  final List<_DayGroup> groups;

  _MonthSection({required this.month, required this.groups});
}

class _TimelineView extends StatefulWidget {
  const _TimelineView();

  @override
  State<_TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<_TimelineView> {
  static const double _maxBubbleSize = 128;
  static const double _minBubbleSize = 96;
  static const int _recencySpan = 6;
  static const double _scatterRange = 14;

  /// Reflection lines shown sparingly between month sections — cycled
  /// deterministically so they don't reshuffle on every rebuild.
  static const int _reflectionEveryNMonths = 3;

  late final TextEditingController _searchController;
  String _query = '';
  MoodType? _moodFilter;
  DateTime? _monthFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_DayGroup> _groupByDay(List<MoodEntryEntity> entries) {
    final byDay = <DateTime, List<MoodEntryEntity>>{};
    for (final entry in entries) {
      final day = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      (byDay[day] ??= []).add(entry);
    }

    final groups = byDay.entries.map((e) {
      final dayEntries = [...e.value]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return _DayGroup(date: e.key, entries: dayEntries);
    }).toList();

    groups.sort((a, b) => b.date.compareTo(a.date));
    return groups;
  }

  List<_DayGroup> _sortedByPin(List<_DayGroup> groups) {
    final pinned = groups.where((g) => g.pinned).toList();
    final rest = groups.where((g) => !g.pinned).toList();
    return [...pinned, ...rest];
  }

  bool _matchesFilters(MoodEntryEntity entry) {
    if (_moodFilter != null && moodTypeFromEmoji(entry.emoji) != _moodFilter) {
      return false;
    }
    if (_monthFilter != null) {
      final matchesMonth = entry.createdAt.year == _monthFilter!.year &&
          entry.createdAt.month == _monthFilter!.month;
      if (!matchesMonth) return false;
    }
    if (_query.trim().isNotEmpty) {
      final needle = _query.trim().toLowerCase();
      final haystack = '${entry.thoughts} ${entry.aiResponse}'.toLowerCase();
      if (!haystack.contains(needle)) return false;
    }
    return true;
  }

  List<_MonthSection> _sections(List<_DayGroup> groups) {
    final byMonth = <DateTime, List<_DayGroup>>{};
    for (final group in groups) {
      final month = DateTime(group.date.year, group.date.month);
      (byMonth[month] ??= []).add(group);
    }

    final sections = byMonth.entries
        .map((e) => _MonthSection(month: e.key, groups: _sortedByPin(e.value)))
        .toList()
      ..sort((a, b) => b.month.compareTo(a.month));
    return sections;
  }

  double _sizeForRank(int rank) {
    final t = (rank / _recencySpan).clamp(0.0, 1.0);
    return _maxBubbleSize - (_maxBubbleSize - _minBubbleSize) * t;
  }

  /// Deterministic per-entry jitter — seeded by the entry's own id so a
  /// given bubble always scatters to the same spot instead of reshuffling
  /// on every rebuild/scroll.
  Offset _scatterFor(int entryId) {
    final random = Random(entryId);
    final dx = (random.nextDouble() * 2 - 1) * _scatterRange;
    final dy = (random.nextDouble() * 2 - 1) * _scatterRange;
    return Offset(dx, dy);
  }

  void _openDay(BuildContext context, _DayGroup group) {
    final history = <Map<String, String>>[];
    for (final entry in group.entries) {
      if (entry.thoughts.isNotEmpty) {
        history.add({'role': 'user', 'content': entry.thoughts});
      }
      if (entry.aiResponse.isNotEmpty) {
        history.add({'role': 'assistant', 'content': entry.aiResponse});
      }
    }

    context.push(
      AppRoutes.chat,
      extra: {
        'userId': group.representative.userId,
        'emoji': group.representative.emoji,
        'history': history,
      },
    );
  }

  String? _reflectionFor(int sectionIndex) {
    if (sectionIndex == 0 || sectionIndex % _reflectionEveryNMonths != 0) {
      return null;
    }
    final l10n = AppLocalizations.of(context)!;
    final pool = [
      l10n.timelineReflection1,
      l10n.timelineReflection2,
      l10n.timelineReflection3,
      l10n.timelineReflection4,
    ];
    return pool[(sectionIndex ~/ _reflectionEveryNMonths - 1) % pool.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final headingColor =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final subheadingColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocBuilder<JournalGridCubit, JournalGridState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.horizontalPaddingLg,
                    AppSpacing.spaceSm,
                    AppSpacing.horizontalPaddingLg,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: headingColor,
                        ),
                        Expanded(
                          child: Text(
                            l10n.timelineTitle,
                            style: ThemeTextStyles.headlineMedium(context)
                                .copyWith(color: headingColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is JournalGridLoaded && state.entries.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.horizontalPaddingLg,
                      AppSpacing.spaceSm,
                      AppSpacing.horizontalPaddingLg,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _TimelineFilters(
                        searchController: _searchController,
                        onSearchChanged: (value) =>
                            setState(() => _query = value),
                        entries: state.entries,
                        selectedMood: _moodFilter,
                        onMoodSelected: (mood) =>
                            setState(() => _moodFilter = mood),
                        selectedMonth: _monthFilter,
                        onMonthSelected: (month) =>
                            setState(() => _monthFilter = month),
                      ),
                    ),
                  ),
                ..._buildBody(context, state, subheadingColor),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    JournalGridState state,
    Color subheadingColor,
  ) {
    if (state is JournalGridInitial || state is JournalGridLoading) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (state is JournalGridError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: ThemeTextStyles.bodyMedium(context),
              ),
            ),
          ),
        ),
      ];
    }

    final entries = (state as JournalGridLoaded).entries;
    if (entries.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📖', style: TextStyle(fontSize: 40.sp)),
                  SizedBox(height: AppSpacing.spaceMd),
                  Text(
                    l10n.journalEmptyStateTitle,
                    style: ThemeTextStyles.headlineSmall(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.spaceSm),
                  Text(
                    l10n.journalGridEmptyMessage,
                    textAlign: TextAlign.center,
                    style: ThemeTextStyles.bodyMedium(context)
                        .copyWith(color: subheadingColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final filtered = entries.where(_matchesFilters).toList();
    if (filtered.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔍', style: TextStyle(fontSize: 40.sp)),
                  SizedBox(height: AppSpacing.spaceMd),
                  Text(
                    l10n.timelineNoResultsTitle,
                    style: ThemeTextStyles.headlineSmall(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.spaceSm),
                  Text(
                    l10n.timelineNoResultsMessage,
                    style: ThemeTextStyles.bodyMedium(context)
                        .copyWith(color: subheadingColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final sections = _sections(_groupByDay(filtered));

    // Each month is one lazily-built sliver item — the scroll view only
    // ever builds the month sections currently near the viewport rather
    // than every bubble in the whole history up front.
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.horizontalPaddingLg,
          AppSpacing.space2Xl,
          AppSpacing.horizontalPaddingLg,
          AppSpacing.space2Xl,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final section = sections[index];
              final reflection = _reflectionFor(index);
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.space2Xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MonthSeparator(month: section.month),
                    if (reflection != null) ...[
                      SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        reflection,
                        style: ThemeTextStyles.bodySmall(context).copyWith(
                          color: subheadingColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.spaceLg),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.spaceXl,
                      runSpacing: AppSpacing.spaceXl,
                      children: [
                        for (var i = 0; i < section.groups.length; i++)
                          Transform.translate(
                            offset: _scatterFor(
                                section.groups[i].representative.id),
                            child: JournalGridCardWidget(
                              entry: section.groups[i].representative,
                              index: i,
                              size: _sizeForRank(i),
                              duration: section.groups[i].conversationDuration,
                              onTap: () => _openDay(context, section.groups[i]),
                              onLongPress: () => showJournalCardOptionsSheet(
                                context,
                                entryId: section.groups[i].representative.id,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
            childCount: sections.length,
          ),
        ),
      ),
    ];
  }
}

class _MonthSeparator extends StatelessWidget {
  const _MonthSeparator({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final label = DateFormat('MMMM yyyy', locale).format(month);
    final color = context.extra.secondaryTextColor;

    return Row(
      children: [
        Expanded(child: Divider(color: color?.withValues(alpha: 0.3))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
          child: Text(
            label,
            style: ThemeTextStyles.labelMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: color?.withValues(alpha: 0.3))),
      ],
    );
  }
}

class _TimelineFilters extends StatelessWidget {
  const _TimelineFilters({
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
    final ordered = MoodType.values.where(moods.contains).toList();
    return ordered;
  }

  List<DateTime> _monthsPresent() {
    final months = <DateTime>{};
    for (final entry in entries) {
      months.add(DateTime(entry.createdAt.year, entry.createdAt.month));
    }
    final ordered = months.toList()..sort((a, b) => b.compareTo(a));
    return ordered;
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
              _FilterChip(
                label: l10n.timelineFilterAllMoods,
                selected: selectedMood == null,
                onTap: () => onMoodSelected(null),
              ),
              for (final mood in _moodsPresent())
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.spaceSm),
                  child: _FilterChip(
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
              _FilterChip(
                label: l10n.timelineFilterAllMonths,
                selected: selectedMonth == null,
                onTap: () => onMonthSelected(null),
              ),
              for (final month in _monthsPresent())
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.spaceSm),
                  child: _FilterChip(
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : extra.cardBackgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : extra.borderColor ?? AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: ThemeTextStyles.labelSmall(context).copyWith(
              color: selected ? AppColors.primary : extra.secondaryTextColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
