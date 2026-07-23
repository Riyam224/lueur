// lib/features/journal/presentation/screens/journal_grid_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_streak_bar_widget.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';

class JournalGridScreen extends StatelessWidget {
  const JournalGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<JournalGridCubit>()..loadEntries()),
        BlocProvider(create: (_) => sl<PlantCubit>()..loadPlant()),
      ],
      child: BlocListener<MoodCubit, MoodState>(
        listenWhen: (previous, current) =>
            current is MoodHistorySuccess &&
            current.justGenerated != null &&
            (previous is! MoodHistorySuccess ||
                previous.justGenerated != current.justGenerated),
        listener: (context, state) {
          unawaited(context.read<JournalGridCubit>().loadEntries());
          unawaited(context.read<PlantCubit>().loadPlant());
        },
        child: const _JournalGridView(),
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
}

class _JournalGridView extends StatelessWidget {
  const _JournalGridView();

  static const double _maxBubbleSize = 128;
  static const double _minBubbleSize = 96;
  static const int _recencySpan = 6;

  /// Groups entries by calendar day — one bubble represents a whole day's
  /// conversation, not a single check-in, since a day can have several
  /// separate mood entries.
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

  List<_DayGroup> _sorted(List<_DayGroup> groups) {
    final pinned = groups.where((g) => g.pinned).toList();
    final rest = groups.where((g) => !g.pinned).toList();
    return [...pinned, ...rest];
  }

  double _sizeForRank(int rank) {
    final t = (rank / _recencySpan).clamp(0.0, 1.0);
    return _maxBubbleSize - (_maxBubbleSize - _minBubbleSize) * t;
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

  Widget _buildBubbles(BuildContext context, List<MoodEntryEntity> entries) {
    final groups = _sorted(_groupByDay(entries));

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.horizontalPaddingLg,
        0,
        AppSpacing.horizontalPaddingLg,
        AppSpacing.space2Xl,
      ),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.spaceMd,
          runSpacing: AppSpacing.spaceMd,
          children: [
            for (var i = 0; i < groups.length; i++)
              JournalGridCardWidget(
                entry: groups[i].representative,
                index: i,
                size: _sizeForRank(i),
                onTap: () => _openDay(context, groups[i]),
                onLongPress: () => showJournalCardOptionsSheet(
                  context,
                  entryId: groups[i].representative.id,
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
        isDark ? AppColors.darkBackground : AppColors.journalGridBackground;
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
                      'your journal',
                      style: ThemeTextStyles.headlineMedium(context).copyWith(
                        color: headingColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spaceSm),
                    Text(
                      'a little collection of your days',
                      style: ThemeTextStyles.bodyMedium(context).copyWith(
                        color: subheadingColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spaceLg),
                    BlocBuilder<PlantCubit, PlantState>(
                      builder: (context, plantState) {
                        final streakDays = plantState is PlantLoaded
                            ? plantState.streakDays
                            : 0;
                        return BlocBuilder<JournalGridCubit, JournalGridState>(
                          builder: (context, state) {
                            final entries = state is JournalGridLoaded
                                ? state.entries
                                : const <MoodEntryEntity>[];
                            return JournalStreakBarWidget(
                              entries: entries,
                              streakDays: streakDays,
                            );
                          },
                        );
                      },
                    ),
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
                          child: Text(
                            'nothing here yet — your days will show up as you go',
                            textAlign: TextAlign.center,
                            style: ThemeTextStyles.bodyMedium(context).copyWith(
                              color: subheadingColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  JournalGridLoaded(:final entries) =>
                    _buildBubbles(context, entries),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
