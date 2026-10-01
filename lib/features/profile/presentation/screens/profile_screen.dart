import 'dart:async';

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
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
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
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// The shell keeps this tab alive, so activities saved elsewhere (drawings,
/// Sudoku, quotes) would otherwise only show up after an app restart —
/// re-read them silently each time /profile becomes the visible route.
class _ProfileScreenState extends State<ProfileScreen> {
  GoRouterDelegate? _routerDelegate;
  bool _wasVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.of(context).routerDelegate;
    if (identical(delegate, _routerDelegate)) return;
    _routerDelegate?.removeListener(_onRouteChanged);
    _routerDelegate = delegate..addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final delegate = _routerDelegate;
    if (!mounted || delegate == null) return;
    if (delegate.currentConfiguration.isEmpty) return;
    // `state` is the top route, including pushed ones — so popping a pushed
    // screen back onto Profile counts as becoming visible, too.
    final isVisible = delegate.state.uri.path == AppRoutes.profile;
    if (isVisible && !_wasVisible) {
      unawaited(context.read<SavedQuotesCubit>().refresh());
      unawaited(context.read<SavedDrawingsCubit>().refresh());
      unawaited(context.read<SudokuResultsCubit>().refresh());
    }
    _wasVisible = isVisible;
  }

  // Only a signed-in account is a "member" — guests get a neutral line.
  static String _subtitle(BuildContext context, AuthState state) =>
      state is AuthAuthenticated
          ? AppLocalizations.of(context)!.profileSubtitle
          : AppLocalizations.of(context)!.profileGuestSubtitle;

  static String _displayName(BuildContext context, AuthState state) =>
      state is AuthAuthenticated
          ? state.user.displayName
          : AppLocalizations.of(context)!.profileFallbackName;

  static String? _userSeed(AuthState state) =>
      state is AuthAuthenticated ? state.user.id : null;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
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
                  subtitle: _subtitle(context, state),
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
                      return _QuotesInfoCard(
                        message: AppLocalizations.of(context)!
                            .profileQuotesEmptySubtitle,
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
                              // push, not go: go would tear down the tab
                              // shell and lose Home/Journal state.
                              onPressed: () => unawaited(
                                context.push(AppRoutes.savedQuotes),
                              ),
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

                  // A failure must not look the same as "no quotes yet".
                  return _QuotesInfoCard(
                    message: state is SavedQuotesError
                        ? AppLocalizations.of(context)!.quotesLoadErrorMessage
                        : AppLocalizations.of(context)!.quotesLoadingMessage,
                  );
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
      ),
    );
  }
}

/// The saved-quotes card for every non-list state: empty, loading or error.
class _QuotesInfoCard extends StatelessWidget {
  final String message;

  const _QuotesInfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(
          color: context.extra.borderColor ??
              Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text('📌', style: TextStyle(fontSize: AppSizes.iconLg)),
          SizedBox(height: AppSpacing.spaceSm),
          Text(
            AppLocalizations.of(context)!.quotesScreenTitle,
            style: ThemeTextStyles.titleMedium(context),
          ),
          SizedBox(height: AppSpacing.spaceXs),
          Text(
            message,
            style: ThemeTextStyles.bodySmall(context).copyWith(
              color: context.extra.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
