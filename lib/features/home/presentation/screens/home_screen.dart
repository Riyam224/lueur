import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/navigation/app_bottom_nav_bar.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/home/presentation/widgets/greeting_card.dart';
import 'package:lueur/features/home/presentation/widgets/home_header.dart';
import 'package:lueur/features/home/presentation/widgets/home_streak_widget.dart';
import 'package:lueur/features/home/presentation/widgets/mood_input_section.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

typedef _HomeMoodSlice = (
  bool isLoading,
  bool hasEntries,
  String? errorMessage
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String _displayName(BuildContext context, AuthState state) =>
      state is AuthAuthenticated
          ? state.user.displayName
          : AppLocalizations.of(context)!.profileFallbackName;

  static String? _userSeed(AuthState state) =>
      state is AuthAuthenticated ? state.user.id : null;

  @override
  Widget build(BuildContext context) {
    final authCubit = sl<AuthCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PlantCubit>()..loadPlant(),
        ),
        BlocProvider.value(
          value: sl<MoodCubit>(),
        ),
        BlocProvider.value(
          value: authCubit,
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => _HomeScreenBody(
          userName: _displayName(context, state),
          userSeed: _userSeed(state),
        ),
      ),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody({
    required this.userName,
    this.userSeed,
  });

  final String userName;
  final String? userSeed;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MoodCubit, MoodState, _HomeMoodSlice>(
      selector: (state) => (
        state is MoodLoading,
        state is MoodHistorySuccess && state.entries.isNotEmpty,
        state is MoodError ? state.message : null,
      ),
      builder: (context, mood) {
        final (isLoading, hasEntries, errorMessage) = mood;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.horizontalPaddingLg,
                AppSpacing.topPaddingSafeArea,
                AppSpacing.horizontalPaddingLg,
                AppSpacing.verticalPaddingLg,
              ),
              sliver: SliverToBoxAdapter(
                child: HomeHeader(
                  userName: userName,
                  userSeed: userSeed,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingLg,
              ),
              sliver: SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ambient gradient bleed softening the hard edge between
                    // the greeting card and mood picker — purely decorative, never affects layout.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -AppSpacing.sectionSpacingLg,
                      height: AppSpacing.sectionSpacingLg,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.pastelOrchid
                                    : AppColors.greetingGradientStart)
                                    .withValues(alpha: 0.22),
                                (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.pastelOrchid
                                    : AppColors.greetingGradientStart)
                                    .withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    GreetingCard(
                      userName: userName,
                      hasEntries: hasEntries,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.horizontalPaddingLg,
                AppSpacing.sectionSpacingSm,
                AppSpacing.horizontalPaddingLg,
                0,
              ),
              sliver: const SliverToBoxAdapter(child: HomeStreakWidget()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.horizontalPaddingLg,
                AppSpacing.sectionSpacingSm,
                AppSpacing.horizontalPaddingLg,
                AppSpacing.sectionSpacingSm,
              ),
              sliver: const SliverToBoxAdapter(child: MoodInputSection()),
            ),
            if (isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.sectionSpacingMd,
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/plant_sprout.json',
                      width: AppSizes.iconXl,
                      height: AppSizes.iconXl,
                      repeat: true,
                    ),
                  ),
                ),
              ),
            if (errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPaddingLg,
                    vertical: AppSpacing.sectionSpacingSm,
                  ),
                  child: Text(
                    errorMessage,
                    style: ThemeTextStyles.bodyMedium(context)
                        .copyWith(color: AppColors.errorColor),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    kBottomNavBarContentHeight +
                    AppSpacing.sectionSpacingSm,
              ),
            ),
          ],
        );
      },
    );
  }
}
