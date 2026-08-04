// lib/features/journal/presentation/screens/journal_grid_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/preferences/streak_celebration_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:lueur/features/home/presentation/widgets/recent_entries_header.dart';
import 'package:lueur/features/home/presentation/widgets/streak_card_widget.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_banner.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';
import 'package:lueur/features/plant/domain/entities/streak_milestone.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Journal is a lightweight entry point into memories — the title, the
/// weekly letter, and a taste of the most recent days. The full searchable,
/// filterable browsing experience lives in [AppRoutes.timeline].
class JournalGridScreen extends StatefulWidget {
  const JournalGridScreen({super.key});

  @override
  State<JournalGridScreen> createState() => _JournalGridScreenState();
}

class _JournalGridScreenState extends State<JournalGridScreen> {
  bool _checkingCelebration = false;

  Future<void> _maybeCelebrateStreak(int streakDays) async {
    if (!StreakMilestone.isMilestone(streakDays) || _checkingCelebration) {
      return;
    }
    _checkingCelebration = true;
    try {
      final lastMilestone = await StreakCelebrationPrefs.lastMilestone();
      if (streakDays <= lastMilestone) return;
      await StreakCelebrationPrefs.markCelebrated(streakDays);
      if (!mounted) return;
      unawaited(
        context.push(
          AppRoutes.streakCelebration,
          extra: {'streakDays': streakDays},
        ),
      );
    } finally {
      _checkingCelebration = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = sl<AuthCubit>().state is AuthGuest;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<JournalGridCubit>()..loadEntries()),
        BlocProvider(create: (_) => sl<PlantCubit>()..loadPlant()),
        if (!isGuest)
          BlocProvider(create: (_) => sl<WeeklyLetterCubit>()..load()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MoodCubit, MoodState>(
            listenWhen: (previous, current) =>
                current is MoodHistorySuccess &&
                current.justGenerated != null &&
                (previous is! MoodHistorySuccess ||
                    previous.justGenerated != current.justGenerated),
            listener: (context, state) {
              unawaited(context.read<JournalGridCubit>().loadEntries());
            },
          ),
          BlocListener<PlantCubit, PlantState>(
            listenWhen: (previous, current) =>
                current is PlantLoaded &&
                StreakMilestone.isMilestone(current.streakDays),
            listener: (context, state) {
              if (state is PlantLoaded) {
                unawaited(_maybeCelebrateStreak(state.streakDays));
              }
            },
          ),
        ],
        child: _JournalGridView(isGuest: isGuest),
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

  Duration? get conversationDuration => entries.length > 1
      ? entries.last.createdAt.difference(entries.first.createdAt)
      : null;
}

class _JournalGridView extends StatelessWidget {
  const _JournalGridView({required this.isGuest});

  final bool isGuest;

  /// A fixed bubble size for the 3-item preview — consistent heights read
  /// calmer here than the Timeline's recency-scaled scatter, which fits a
  /// full page of history rather than a 3-item taste of it.
  static const double _previewBubbleSize = 116;
  static const double _scatterRange = 10;

  List<_DayGroup> _latestDayGroups(List<MoodEntryEntity> entries, int limit) {
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
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return groups.take(limit).toList();
  }

  /// Deterministic per-entry jitter — seeded by the entry's own id so a
  /// given bubble always scatters to the same spot instead of reshuffling
  /// on every rebuild.
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

  Widget _buildRecentMemories(
    BuildContext context,
    List<MoodEntryEntity> entries,
  ) {
    final groups = _latestDayGroups(entries, 3);

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.horizontalPaddingLg,
        AppSpacing.spaceLg,
        AppSpacing.horizontalPaddingLg,
        AppSpacing.space2Xl,
      ),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.spaceXl,
          runSpacing: AppSpacing.spaceXl,
          children: [
            for (var i = 0; i < groups.length; i++)
              Transform.translate(
                offset: _scatterFor(groups[i].representative.id),
                child: JournalGridCardWidget(
                  entry: groups[i].representative,
                  index: i,
                  size: _previewBubbleSize,
                  duration: groups[i].conversationDuration,
                  onTap: () => _openDay(context, groups[i]),
                  onLongPress: () => showJournalCardOptionsSheet(
                    context,
                    entryId: groups[i].representative.id,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingLg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.spaceLg),
                    Text(
                      AppLocalizations.of(context)!.journalGridTitle,
                      style: ThemeTextStyles.headlineMedium(context).copyWith(
                        color: headingColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spaceSm),
                    Text(
                      AppLocalizations.of(context)!.journalGridSubtitle,
                      style: ThemeTextStyles.bodyMedium(context).copyWith(
                        color: subheadingColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spaceLg),
                    BlocBuilder<MoodCubit, MoodState>(
                      builder: (context, moodState) {
                        final entries = moodState is MoodHistorySuccess
                            ? moodState.entries
                            : <MoodEntryEntity>[];
                        return BlocBuilder<PlantCubit, PlantState>(
                          builder: (context, plantState) {
                            final streakDays = plantState is PlantLoaded
                                ? plantState.streakDays
                                : 0;
                            return StreakCardWidget(
                              entries: entries,
                              streakDays: streakDays,
                            );
                          },
                        );
                      },
                    ),
                    if (!isGuest) ...[
                      SizedBox(height: AppSpacing.spaceLg),
                      const WeeklyLetterBanner(),
                    ],
                    SizedBox(height: AppSpacing.spaceLg),
                  ],
                ),
              ),
            ),
            BlocBuilder<JournalGridCubit, JournalGridState>(
              builder: (context, state) {
                return switch (state) {
                  JournalGridInitial() ||
                  JournalGridLoading() =>
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  JournalGridError(:final message) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding:
                              EdgeInsets.all(AppSpacing.horizontalPaddingLg),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: ThemeTextStyles.bodyMedium(context),
                          ),
                        ),
                      ),
                    ),
                  JournalGridLoaded(:final entries) when entries.isEmpty =>
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding:
                              EdgeInsets.all(AppSpacing.horizontalPaddingLg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('📖', style: TextStyle(fontSize: 40.sp)),
                              SizedBox(height: AppSpacing.spaceMd),
                              Text(
                                AppLocalizations.of(context)!
                                    .journalEmptyStateTitle,
                                style: ThemeTextStyles.headlineSmall(context),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSpacing.spaceSm),
                              Text(
                                AppLocalizations.of(context)!
                                    .journalGridEmptyMessage,
                                textAlign: TextAlign.center,
                                style: ThemeTextStyles.bodyMedium(context)
                                    .copyWith(color: subheadingColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  JournalGridLoaded(:final entries) => SliverMainAxisGroup(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.horizontalPaddingLg,
                            0,
                            AppSpacing.horizontalPaddingLg,
                            0,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: RecentEntriesHeader(),
                          ),
                        ),
                        _buildRecentMemories(context, entries),
                      ],
                    ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
