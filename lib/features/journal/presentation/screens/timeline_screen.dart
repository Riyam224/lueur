import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_body_slivers.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_filters_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_header_widget.dart';
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

class _TimelineView extends StatefulWidget {
  const _TimelineView();

  @override
  State<_TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<_TimelineView> {
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

  void _openDay(BuildContext context, DayGroup group) {
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
                    child: TimelineHeaderWidget(
                      title: l10n.timelineTitle,
                      headingColor: headingColor,
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
                      child: TimelineFiltersWidget(
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
                ...buildTimelineBodySlivers(
                  context,
                  state: state,
                  subheadingColor: subheadingColor,
                  moodFilter: _moodFilter,
                  monthFilter: _monthFilter,
                  query: _query,
                  onOpenDay: (group) => _openDay(context, group),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
