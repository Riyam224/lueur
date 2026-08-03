import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/utils/streak_calculator.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_avatar_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_journal_data_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_quick_links_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_saved_drawings_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_settings_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_stats_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_sudoku_history_section_widget.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static String _subtitle(BuildContext context) =>
      AppLocalizations.of(context)!.profileSubtitle;

  static String _displayName(BuildContext context, AuthState state) =>
      state is AuthAuthenticated
          ? state.user.displayName
          : AppLocalizations.of(context)!.profileFallbackName;

  static String? _userSeed(AuthState state) =>
      state is AuthAuthenticated ? state.user.id : null;

  static int _thisWeekCount(List<MoodEntryEntity> entries) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return entries.where((e) => !e.createdAt.isBefore(start)).length;
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
            child: Text(
              AppLocalizations.of(context)!.profileTitle,
              style: ThemeTextStyles.headlineMedium(context),
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
                name: _displayName(context, state),
                subtitle: _subtitle(context),
                seed: _userSeed(state),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  AppLocalizations.of(context)!.profileStatsSectionLabel,
                ),
                SizedBox(height: AppSpacing.verticalPaddingSm),
                BlocBuilder<MoodCubit, MoodState>(
                  builder: (context, state) {
                    final entries = state is MoodHistorySuccess
                        ? state.entries
                        : <MoodEntryEntity>[];
                    return ProfileStatsWidget(
                      totalEntries: entries.length,
                      thisWeek: _thisWeekCount(entries),
                      dayStreak: StreakCalculator.calculateConsecutiveStreak(
                        entries.map((e) => e.createdAt).toList(),
                      ),
                    );
                  },
                ),
              ],
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
                        borderRadius:
                            BorderRadius.circular(AppSizes.borderRadiusLg),
                        border: Border.all(
                          color: context.extra.borderColor ??
                              Theme.of(context).colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('📌',
                              style: TextStyle(fontSize: AppSizes.iconLg)),
                          SizedBox(height: AppSpacing.spaceSm),
                          Text(
                            AppLocalizations.of(context)!.quotesScreenTitle,
                            style: ThemeTextStyles.titleMedium(context),
                          ),
                          SizedBox(height: AppSpacing.spaceXs),
                          Text(
                            AppLocalizations.of(context)!
                                .profileQuotesEmptySubtitle,
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
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.quotesScreenTitle,
                              overflow: TextOverflow.ellipsis,
                              style: ThemeTextStyles.headlineSmall(context),
                            ),
                          ),
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
                                borderRadius: BorderRadius.circular(
                                    AppSizes.borderRadiusLg),
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
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontFamilyFallback: const [
                                              'Apple Color Emoji',
                                              'Noto Color Emoji',
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.spaceSm),
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
                                        color: context.extra.secondaryTextColor,
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

        // ── My Drawings ──────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingMd,
          ),
          sliver: const SliverToBoxAdapter(
            child: ProfileSavedDrawingsSectionWidget(),
          ),
        ),

        // ── Sudoku History ────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingMd,
          ),
          sliver: const SliverToBoxAdapter(
            child: ProfileSudokuHistorySectionWidget(),
          ),
        ),

        // ── Weekly Letter / Mood Board quick links ────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingLg,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  AppLocalizations.of(context)!.profileQuickLinksSectionLabel,
                ),
                SizedBox(height: AppSpacing.verticalPaddingSm),
                const ProfileQuickLinksWidget(),
              ],
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

        // ── Journal Data (destructive) ────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingLg,
          ),
          sliver: const SliverToBoxAdapter(
            child: ProfileJournalDataSectionWidget(),
          ),
        ),

        // ── Logout button ─────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            100.h,
          ),
          sliver: SliverToBoxAdapter(
            child: TextButton.icon(
              onPressed: () => context.read<AuthCubit>().logout(),
              icon:
                  const Icon(Icons.logout_rounded, color: AppColors.errorColor),
              label: Text(
                AppLocalizations.of(context)!.authLogOut,
                style: ThemeTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  side: BorderSide(
                    color: AppColors.errorColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small-caps section header, matching the style already established by
/// [ProfileSettingsSectionWidget]'s "SETTINGS" label — reused here so every
/// major group on the profile screen reads consistently.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: ThemeTextStyles.labelSmall(context).copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
