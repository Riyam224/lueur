// lib/features/journal/presentation/screens/journal_grid_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
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
      child: const _JournalGridView(),
    );
  }
}

class _JournalGridView extends StatelessWidget {
  const _JournalGridView();

  void _openEntry(BuildContext context, MoodEntryEntity entry) {
    context.push(
      AppRoutes.chat,
      extra: {
        'userId': entry.userId,
        'emoji': entry.emoji,
        'thoughts': entry.thoughts,
        'aiResponse': entry.aiResponse,
      },
    );
  }

  List<MoodEntryEntity> _sorted(List<MoodEntryEntity> entries) {
    final pinned = entries.where((e) => e.pinned).toList();
    final rest = entries.where((e) => !e.pinned).toList();
    return [...pinned, ...rest];
  }

  Widget _buildGrid(BuildContext context, List<MoodEntryEntity> entries) {
    final sortedEntries = _sorted(entries);
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.horizontalPaddingLg,
        0,
        AppSpacing.horizontalPaddingLg,
        AppSpacing.space2Xl,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.spaceMd,
          crossAxisSpacing: AppSpacing.spaceMd,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = sortedEntries[index];
            return JournalGridCardWidget(
              entry: entry,
              index: index,
              onTap: () => _openEntry(context, entry),
              onLongPress: () =>
                  showJournalCardOptionsSheet(context, entryId: entry.id),
            );
          },
          childCount: sortedEntries.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.journalGridBackground,
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
                        color: AppColors.lightOnBackground,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spaceSm),
                    Text(
                      'a little collection of your days',
                      style: ThemeTextStyles.bodyMedium(context).copyWith(
                        color: AppColors.lightSecondaryText,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spaceLg),
                    BlocBuilder<PlantCubit, PlantState>(
                      builder: (context, plantState) {
                        final streakDays =
                            plantState is PlantLoaded ? plantState.streakDays : 0;
                        return BlocBuilder<JournalGridCubit, JournalGridState>(
                          builder: (context, state) {
                            final entries =
                                state is JournalGridLoaded ? state.entries : const <MoodEntryEntity>[];
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
                  JournalGridInitial() || JournalGridLoading() => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  JournalGridError(:final message) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
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
                          padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
                          child: Text(
                            'nothing here yet — your days will show up as you go',
                            textAlign: TextAlign.center,
                            style: ThemeTextStyles.bodyMedium(context).copyWith(
                              color: AppColors.lightSecondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  JournalGridLoaded(:final entries) => _buildGrid(context, entries),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
