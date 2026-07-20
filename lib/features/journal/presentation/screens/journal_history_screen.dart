import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_entry.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/mood_entry_card.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_emoji_filter_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_header_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_mood_graph_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_search_bar_widget.dart';

class JournalHistoryScreen extends StatelessWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _JournalBody();
  }
}

class _JournalBody extends StatefulWidget {
  const _JournalBody();

  @override
  State<_JournalBody> createState() => _JournalBodyState();
}

class _JournalBodyState extends State<_JournalBody> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedEmoji;
  String _searchQuery = '';
  final ValueNotifier<double> _pullExtent = ValueNotifier<double>(0);
  bool _isRefreshing = false;

  static const double _triggerExtent = 90;
  static const double _maxExtent = 140;

  @override
  void dispose() {
    _searchController.dispose();
    _pullExtent.dispose();
    super.dispose();
  }

  MoodEntry _entityToUiEntry(MoodEntryEntity e) {
    return MoodEntry(
      id: e.id,
      emoji: e.emoji,
      title: _titleFromThoughts(e.thoughts),
      preview: e.aiResponse,
      sideColor: _colorForEmoji(e.emoji),
      date: e.createdAt,
    );
  }

  String _titleFromThoughts(String thoughts) {
    final sentence = thoughts.split(RegExp(r'[.!?]')).first.trim();
    if (sentence.isEmpty) return thoughts;
    return sentence.length > 40 ? '${sentence.substring(0, 40)}…' : sentence;
  }

  Color _colorForEmoji(String emoji) {
    return moodTypeFromEmoji(emoji)?.color ?? AppColors.moodNeutral;
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all entries?'),
        content: const Text('This will permanently remove all journal entries from your device.'),
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
            child: const Text('Delete all', style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }

  List<MoodEntry> _filterAndMap(List<MoodEntryEntity> entities) {
    return entities
        .where((e) {
          final matchesSearch = _searchQuery.isEmpty ||
              e.thoughts.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.aiResponse.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesEmoji =
              _selectedEmoji == null || e.emoji == _selectedEmoji;
          return matchesSearch && matchesEmoji;
        })
        .map(_entityToUiEntry)
        .toList();
  }

  String _formatTodayLabel() {
    final now = DateTime.now();
    final formatted = DateFormat('EEEE, MMMM d').format(now);
    return 'Today — $formatted';
  }

  int _calculateStreakDays(List<MoodEntryEntity> entries) {
    if (entries.isEmpty) return 0;
    final dates = entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);
    for (final date in dates) {
      if (DateUtils.isSameDay(date, day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else if (date.isAfter(day)) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  String _moodLabel(String emoji) {
    return moodTypeFromEmoji(emoji)?.label ?? 'Okay';
  }

  String _todayMoodSummary(List<MoodEntryEntity> entries) {
    final today = DateTime.now();
    final todayEntries = entries.where((e) {
      return DateUtils.isSameDay(e.createdAt, today);
    }).toList();
    if (todayEntries.isEmpty) {
      return 'No entries yet · Start with one gentle thought';
    }
    final emojiCounts = <String, int>{};
    for (final entry in todayEntries) {
      emojiCounts.update(entry.emoji, (v) => v + 1, ifAbsent: () => 1);
    }
    final topEmoji = emojiCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final label = _moodLabel(topEmoji);
    final count = todayEntries.length;
    final entryLabel = count == 1 ? 'entry' : 'entries';
    final streak = _calculateStreakDays(entries);
    return 'You felt $topEmoji $label · $count $entryLabel · $streak day streak 🔥';
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await context.read<MoodCubit>().getHistory();
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _isRefreshing = false);
    _pullExtent.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoodCubit, MoodState>(
      builder: (context, state) {
        final allEntities = state is MoodHistorySuccess
            ? state.entries
            : <MoodEntryEntity>[];
        final filtered = _filterAndMap(allEntities);
        final showEmpty =
            state is! MoodLoading && state is! MoodError && allEntities.isEmpty;
        final showSummary = allEntities.isNotEmpty;

        return Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final pixels = notification.metrics.pixels;
                if (pixels < 0) {
                  _pullExtent.value = (-pixels).clamp(0, _maxExtent);
                } else if (notification is ScrollUpdateNotification &&
                    notification.dragDetails != null) {
                  if (_pullExtent.value != 0) _pullExtent.value = 0;
                }

                if (notification is ScrollEndNotification) {
                  if (_pullExtent.value >= _triggerExtent && !_isRefreshing) {
                    _handleRefresh();
                  } else if (!_isRefreshing) {
                    _pullExtent.value = 0;
                  }
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
            // ── Header ──────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.horizontalPaddingLg,
                AppSpacing.topPaddingSafeArea,
                AppSpacing.horizontalPaddingLg,
                AppSpacing.verticalPaddingMd,
              ),
              sliver: SliverToBoxAdapter(
                child: JournalHeaderWidget(
                  entryCount: allEntities.length,
                  onDeleteAll: allEntities.isEmpty
                      ? null
                      : () => _confirmDeleteAll(context),
                ),
              ),
            ),

            if (showSummary)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPaddingLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.spaceLg),
                    decoration: BoxDecoration(
                      color: context.extra.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.extra.borderColor ?? AppColors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTodayLabel(),
                          style: ThemeTextStyles.labelSmall(context).copyWith(
                            color: context.extra.secondaryTextColor,
                          ),
                        ),
                        SizedBox(height: AppSpacing.spaceSm),
                        Text(
                          _todayMoodSummary(allEntities),
                          style: ThemeTextStyles.bodyMedium(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Search bar ───────────────────────────────────
            if (!showEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPaddingLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: JournalSearchBarWidget(
                    controller: _searchController,
                    onChanged: (query) => setState(() => _searchQuery = query),
                  ),
                ),
              ),

            // ── Emoji filter row ─────────────────────────────
            if (!showEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                ),
                sliver: SliverToBoxAdapter(
                  child: JournalEmojiFilterWidget(
                    selectedEmoji: _selectedEmoji,
                    onEmojiSelected: (emoji) =>
                        setState(() => _selectedEmoji = emoji),
                  ),
                ),
              ),

            // ── Mood graph ───────────────────────────────────
            if (allEntities.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingLg,
                  0,
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.sectionSpacingSm,
                ),
                sliver: SliverToBoxAdapter(
                  child: JournalMoodGraphWidget(entries: allEntities),
                ),
              ),

            // ── Loading ──────────────────────────────────────
            if (state is MoodLoading)
              SliverFillRemaining(
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/plant_sprout.json',
                    width: 56,
                    height: 56,
                    repeat: true,
                  ),
                ),
              )

            // ── Error ────────────────────────────────────────
            else if (state is MoodError)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_outlined,
                          size: 48, color: Theme.of(context).colorScheme.outline,),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: ThemeTextStyles.bodyMedium(context),
                      ),
                    ],
                  ),
                ),
              )

            // ── Empty ────────────────────────────────────────
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPaddingLg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🌱',
                          style: TextStyle(fontSize: 56),
                        ),
                        SizedBox(height: AppSpacing.spaceLg),
                        Text(
                          'Your story starts here',
                          style: ThemeTextStyles.headlineSmall(context),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.spaceSm),
                        Text(
                          'What\'s on your mind today?',
                          style: ThemeTextStyles.bodyMedium(context).copyWith(
                            color: context.extra.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.spaceLg),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go(AppRoutes.home),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.extra.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.verticalPaddingLg,
                              ),
                            ),
                            child: Text(
                              'Start journaling',
                              style: ThemeTextStyles.whiteButton(context)
                                  .copyWith(
                                color: context.extra.onPrimaryTextColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.sectionSpacingLg),
                      ],
                    ),
                  ),
                ),
              )

            // ── Entries list ─────────────────────────────────
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPaddingLg,
                  0,
                  AppSpacing.horizontalPaddingLg,
                  AppSpacing.verticalPaddingLg,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = filtered[index];
                      return Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Delete entry?'),
                                  content: const Text(
                                    'This will permanently remove this journal entry.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: AppColors.errorColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (_) {
                          context.read<MoodCubit>().deleteEntry(entry.id);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.whiteTextColor,
                            size: 26,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.spaceMd),
                          child: MoodEntryCard(
                            emoji: entry.emoji,
                            title: entry.title,
                            preview: entry.preview,
                            sideColor: entry.sideColor,
                            date: entry.date,
                            isEmojiImage: entry.isEmojiImage,
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sectionSpacingLg),
            ),
                ],
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _pullExtent,
              builder: (context, extent, child) {
                if (!_isRefreshing && extent <= 0) {
                  return const SizedBox.shrink();
                }

                final height = _isRefreshing
                    ? _triggerExtent.toDouble()
                    : extent.clamp(0.0, _triggerExtent.toDouble()).toDouble();
                final opacity = _isRefreshing
                    ? 1.0
                    : (extent / _triggerExtent).clamp(0.0, 1.0).toDouble();

                return IgnorePointer(
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: opacity,
                        child: SizedBox(
                          height: height,
                          child: Lottie.asset(
                            'assets/lottie/plant_sprout.json',
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
