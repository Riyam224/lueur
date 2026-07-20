import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_avatar_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_settings_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_stats_widget.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _subtitle = 'MindEase member';

  static String _displayName(AuthState state) =>
      state is AuthAuthenticated ? state.user.displayName : 'Friend';

  static int _thisWeekCount(List<MoodEntryEntity> entries) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return entries.where((e) => !e.createdAt.isBefore(start)).length;
  }

  static int _calculateStreak(List<MoodEntryEntity> entries) {
    if (entries.isEmpty) return 0;
    final dates = entries
        .map((e) =>
            DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day),)
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Profile',
                    style: ThemeTextStyles.headlineMedium(context),),

                // Settings gear icon
                Container(
                  width: AppSizes.avatarSm,
                  height: AppSizes.avatarSm,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.extra.cardBackgroundColor,
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: context.extra.secondaryTextColor,
                    size: AppSizes.iconSm,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Avatar + Name ────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingLg,
          ),
          sliver: SliverToBoxAdapter(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) => ProfileAvatarWidget(
                name: _displayName(state),
                subtitle: _subtitle,
              ),
            ),
          ),
        ),

        // ── Stats row ────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingMd,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingMd,
          ),
          sliver: SliverToBoxAdapter(
            child: BlocBuilder<MoodCubit, MoodState>(
              builder: (context, state) {
                final entries = state is MoodHistorySuccess
                    ? state.entries
                    : <MoodEntryEntity>[];
                return ProfileStatsWidget(
                  totalEntries: entries.length,
                  thisWeek: _thisWeekCount(entries),
                  dayStreak: _calculateStreak(entries),
                );
              },
            ),
          ),
        ),

        // ── Saved Quotes ─────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingMd,
          ),
          sliver: SliverToBoxAdapter(
            child: BlocBuilder<SavedQuotesCubit, SavedQuotesState>(
              builder: (context, state) {
                if (state is SavedQuotesLoaded) {
                  if (state.quotes.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.spaceLg),
                      decoration: BoxDecoration(
                        color: context.extra.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.extra.borderColor ??
                              Theme.of(context).colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('📌', style: TextStyle(fontSize: 32)),
                          SizedBox(height: AppSpacing.spaceSm),
                          Text(
                            'Saved quotes',
                            style: ThemeTextStyles.titleMedium(context),
                          ),
                          SizedBox(height: AppSpacing.spaceXs),
                          Text(
                            'Your saved Luna moments will appear here',
                            style: ThemeTextStyles.bodySmall(context).copyWith(
                              color: context.extra.secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Saved quotes',
                            style: ThemeTextStyles.headlineSmall(context),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => context.go(AppRoutes.savedQuotes),
                            icon: const Icon(Icons.chevron_right_rounded),
                            color: context.extra.tertiaryTextColor,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.spaceSm),
                      ...state.quotes.take(2).map(
                            (quote) => Container(
                              width: double.infinity,
                              margin:
                                  EdgeInsets.only(bottom: AppSpacing.spaceMd),
                              padding: EdgeInsets.all(AppSpacing.spaceLg),
                              decoration: BoxDecoration(
                                color: context.extra.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: context.extra.borderColor ??
                                      Theme.of(context).colorScheme.outline,
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (quote.emoji != null) ...[
                                        Text(
                                          quote.emoji!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontFamilyFallback: [
                                              'Apple Color Emoji',
                                              'Noto Color Emoji',
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          '"${quote.text}"',
                                          style: ThemeTextStyles.bodyMedium(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (quote.thoughts != null &&
                                      quote.thoughts!.isNotEmpty) ...[
                                    SizedBox(height: AppSpacing.spaceXs),
                                    Text(
                                      quote.thoughts!,
                                      style: ThemeTextStyles.bodySmall(context)
                                          .copyWith(
                                        color:
                                            context.extra.secondaryTextColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        // ── Settings section ─────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingLg,
          ),
          sliver: const SliverToBoxAdapter(
            child: ProfileSettingsSectionWidget(),
          ),
        ),

        // ── Logout button ─────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            100,
          ),
          sliver: SliverToBoxAdapter(
            child: TextButton.icon(
              onPressed: () => context.read<AuthCubit>().logout(),
              icon:
                  const Icon(Icons.logout_rounded, color: AppColors.errorColor),
              label: Text(
                'Log out',
                style: ThemeTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: AppColors.errorColor.withValues(alpha: 0.3),),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
