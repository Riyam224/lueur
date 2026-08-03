import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/home/presentation/widgets/greeting_card.dart';
import 'package:lueur/features/home/presentation/widgets/home_header.dart';
import 'package:lueur/features/home/presentation/widgets/mood_input_section.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Home screen — main entry point of the app
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
    return BlocBuilder<MoodCubit, MoodState>(
      builder: (context, state) {
        final hasEntries =
            state is MoodHistorySuccess && state.entries.isNotEmpty;

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
                child: HomeHeader(
                  userName: userName,
                  userSeed: userSeed,
                ),
              ),
            ),

            // Greeting card
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingLg,
              ),
              sliver: SliverToBoxAdapter(
                child: GreetingCard(
                  userName: userName,
                  hasEntries: hasEntries,
                ),
              ),
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

            // Loading indicator
            if (state is MoodLoading)
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

            // Error message
            if (state is MoodError)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPaddingLg,
                    vertical: AppSpacing.sectionSpacingSm,
                  ),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.errorColor),
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sectionSpacingLg),
            ),
          ],
        );
      },
    );
  }
}
