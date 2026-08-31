import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/core/preferences/streak_celebration_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_body.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_header.dart';
import 'package:lueur/features/plant/domain/entities/streak_milestone.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';

/// Journal is a lightweight entry point into memories — title, weekly letter,
/// and a taste of recent days. Full searchable browsing lives in [AppRoutes.timeline].
class JournalGridScreen extends StatefulWidget {
  const JournalGridScreen({super.key});

  @override
  State<JournalGridScreen> createState() => _JournalGridScreenState();
}

class _JournalGridScreenState extends State<JournalGridScreen> {
  bool _checkingCelebration = false;

  Future<void> _maybeCelebrateStreak(int streakDays) async {
    if (!StreakMilestone.isMilestone(streakDays) || _checkingCelebration) {
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final isGuest = sl<AuthCubit>().state is AuthGuest;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<JournalGridCubit>()..loadEntries()),
        BlocProvider(create: (_) => sl<PlantCubit>()..loadPlant()),
        BlocProvider.value(value: sl<JournalRefreshSignal>()),
        if (!isGuest)
          BlocProvider(create: (_) => sl<WeeklyLetterCubit>()..load()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<JournalRefreshSignal, int>(
            listener: (context, state) {
              unawaited(context.read<JournalGridCubit>().loadEntries());
            },
          ),
          BlocListener<PlantCubit, PlantState>(
            listenWhen: (previous, current) =>
                current is PlantLoaded &&
                StreakMilestone.isMilestone(current.streakDays),
            listener: (context, state) {
              if (state is PlantLoaded) {
                unawaited(_maybeCelebrateStreak(state.streakDays));
              }
            },
          ),
        ],
        child: _JournalGridView(isGuest: isGuest),
      ),
    );
  }
}

class _JournalGridView extends StatelessWidget {
  const _JournalGridView({required this.isGuest});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final headingColor =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final subheadingColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingLg,
              ),
              sliver: SliverToBoxAdapter(
                child: JournalGridHeader(
                  headingColor: headingColor,
                  subheadingColor: subheadingColor,
                  isGuest: isGuest,
                ),
              ),
            ),
            JournalGridBody(subheadingColor: subheadingColor),
          ],
        ),
      ),
    );
  }
}
