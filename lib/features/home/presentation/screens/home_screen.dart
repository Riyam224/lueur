import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/models/mood_entry.dart';
import 'package:lueur/core/preferences/streak_celebration_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:lueur/features/home/presentation/widgets/greeting_card.dart';
import 'package:lueur/features/home/presentation/widgets/home_header.dart';
import 'package:lueur/features/home/presentation/widgets/mood_input_section.dart';
import 'package:lueur/features/home/presentation/widgets/recent_entries_header.dart';
import 'package:lueur/features/home/presentation/widgets/recent_entries_list.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_banner.dart';
import 'package:lueur/features/plant/domain/entities/streak_growth_stage.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';

/// Home screen — main entry point of the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String _displayName(AuthState state) =>
      state is AuthAuthenticated ? state.user.displayName : 'Friend';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PlantCubit>()..loadPlant(),
        ),
        BlocProvider.value(
          value: sl<MoodCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<WeeklyLetterCubit>()..load(),
        ),
        BlocProvider.value(
          value: sl<AuthCubit>(),
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) =>
            _HomeScreenBody(userName: _displayName(state)),
      ),
    );
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody({required this.userName});

  final String userName;

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  int _lastEntryCount = 0;
  bool _confettiShown = false;

  /// Guards against re-checking/re-navigating for the same milestone while
  /// the async Hive lookup in [_maybeCelebrateStreak] is still in flight.
  bool _checkingCelebration = false;

  Future<void> _maybeCelebrateStreak(int streakDays) async {
    if (!StreakGrowthStage.isCelebrationDay(streakDays)) return;
    if (_checkingCelebration) return;
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

  /// Maps a MoodEntryEntity (from API) to a MoodEntry (UI model)
  List<MoodEntry> _toUiEntries(
    BuildContext context,
    List<MoodEntryEntity> entities,
  ) {
    return entities.map((e) => _entityToUiEntry(context, e)).toList();
  }

  MoodEntry _entityToUiEntry(BuildContext context, MoodEntryEntity e) {
    return MoodEntry(
      id: e.id,
      emoji: e.emoji,
      title: _titleFromThoughts(e.thoughts),
      preview: e.thoughts,
      sideColor: _emojiColor(e.emoji),
      date: e.createdAt,
    );
  }

  /// Use the first sentence or first 40 chars of thoughts as the card title
  String _titleFromThoughts(String thoughts) {
    final sentence = thoughts.split(RegExp(r'[.!?]')).first.trim();
    if (sentence.isEmpty) return thoughts;
    return sentence.length > 40 ? '${sentence.substring(0, 40)}…' : sentence;
  }

  Color _emojiColor(String emoji) {
    const colors = {
      '😔': AppColors.primary,
      '😊': AppColors.moodHappy,
      '😃': AppColors.moodHappy,
      '😢': AppColors.moodCalm,
      '😭': AppColors.moodCalm,
      '😰': AppColors.moodAnxious,
      '😩': AppColors.moodAnxious,
      '😤': AppColors.moodSad,
      '😌': AppColors.lavender,
      '🥰': AppColors.blushPink,
      '🤩': AppColors.moodExcited,
      '😴': AppColors.lavender,
      '😡': AppColors.moodAnxious,
    };
    return colors[emoji] ?? AppColors.moodNeutral;
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all entries?'),
        content: const Text(
          'This will permanently remove all journal entries from your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MoodCubit>().deleteAllEntries();
            },
            child: const Text(
              'Delete all',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlantCubit, PlantState>(
      listenWhen: (previous, current) =>
          current is PlantLoaded &&
          StreakGrowthStage.isCelebrationDay(current.streakDays),
      listener: (context, state) {
        if (state is PlantLoaded) {
          unawaited(_maybeCelebrateStreak(state.streakDays));
        }
      },
      child: BlocBuilder<MoodCubit, MoodState>(
        builder: (context, state) {
          final entries = switch (state) {
            MoodHistorySuccess(:final entries) =>
              _toUiEntries(context, entries),
            _ => <MoodEntry>[],
          };
          final hasEntries = state is MoodHistorySuccess && entries.isNotEmpty;
          final showEmpty = state is MoodHistorySuccess && entries.isEmpty;
          final shouldShowConfetti = state is MoodHistorySuccess &&
              entries.length == 1 &&
              _lastEntryCount == 0 &&
              !_confettiShown;

          if (state is MoodHistorySuccess) {
            _lastEntryCount = entries.length;
          }

          return CustomScrollView(
            slivers: [
              // Header
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.topPaddingSafeArea,
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.verticalPaddingLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: HomeHeader(userName: widget.userName),
                ),
              ),

              // Greeting card
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPaddingLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: GreetingCard(
                    userName: widget.userName,
                    hasEntries: hasEntries,
                  ),
                ),
              ),

              // Weekly letter banner
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                  AppSpacing.horizontalPaddingLg,
                  0,
                ),
                sliver: const SliverToBoxAdapter(child: WeeklyLetterBanner()),
              ),

              // Mood Input Section
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                ),
                sliver: const SliverToBoxAdapter(child: MoodInputSection()),
              ),

              // Recent entries header
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                ),
                sliver: SliverToBoxAdapter(
                  child: RecentEntriesHeader(
                    onDeleteAll: entries.isEmpty
                        ? null
                        : () => _confirmDeleteAll(context),
                  ),
                ),
              ),

              // Loading indicator
              if (state is MoodLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/plant_sprout.json',
                        width: 48,
                        height: 48,
                        repeat: true,
                      ),
                    ),
                  ),
                ),

              // Error message
              if (state is MoodError)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPaddingLg,
                      vertical: 16,
                    ),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.errorColor),
                    ),
                  ),
                ),

              // Recent entries list
              if (entries.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.horizontalPaddingLg,
                    0,
                    AppSpacing.horizontalPaddingLg,
                    AppSpacing.verticalPaddingLg,
                  ),
                  sliver: RecentEntriesList(
                    entries: entries,
                    onDelete: (id) => context.read<MoodCubit>().deleteEntry(id),
                  ),
                ),

              if (showEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.horizontalPaddingLg,
                      AppSpacing.sectionSpacingSm,
                      AppSpacing.horizontalPaddingLg,
                      AppSpacing.sectionSpacingSm,
                    ),
                    child: Column(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 44)),
                        SizedBox(height: AppSpacing.spaceMd),
                        Text(
                          'Your story starts here',
                          style: ThemeTextStyles.headlineSmall(context),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.spaceSm),
                        Text(
                          'Share a thought and tap Talk to Luna',
                          style: ThemeTextStyles.bodyMedium(context).copyWith(
                            color: context.extra.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.sectionSpacingLg),
              ),

              if (shouldShowConfetti)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPaddingLg,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPaddingLg,
                        vertical: AppSpacing.verticalPaddingLg,
                      ),
                      decoration: BoxDecoration(
                        color: context.extra.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              context.extra.borderColor ?? AppColors.cardBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.extra.shadowColor ?? Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/lottie/blooming.json',
                            width: 140,
                            height: 140,
                            repeat: false,
                            onLoaded: (_) {
                              if (!_confettiShown) {
                                setState(() => _confettiShown = true);
                              }
                            },
                          ),
                          SizedBox(height: AppSpacing.spaceMd),
                          Text(
                            'You just planted your first seed 🌱',
                            style: ThemeTextStyles.headlineSmall(context),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.spaceSm),
                          Text(
                            'Luna is so happy you\'re here!',
                            style: ThemeTextStyles.bodyMedium(context).copyWith(
                              color: context.extra.secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
