import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_account_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_auth_action_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_avatar_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_journal_data_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_saved_drawings_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_settings_section_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_sudoku_history_section_widget.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_state.dart';
import 'package:lueur/features/quotes/presentation/widgets/saved_quote_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
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
                            (quote) => SavedQuoteCard(
                              quote: quote,
                              emojiFontSize: 18,
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

        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.sectionSpacingLg,
          ),
          sliver: const SliverToBoxAdapter(
            child: ProfileAccountSectionWidget(),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            0,
            AppSpacing.horizontalPaddingLg,
            100.h,
          ),
          sliver: const SliverToBoxAdapter(
            child: ProfileAuthActionWidget(),
          ),
        ),
      ],
    );
  }
}
