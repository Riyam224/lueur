import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_content.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_shell.dart';

/// Floating dismissible weekly-letter card shown at the top of the home screen.
/// The user swipes it away (or taps ×) to hide it for this session.
class WeeklyLetterBanner extends StatefulWidget {
  const WeeklyLetterBanner({super.key});

  @override
  State<WeeklyLetterBanner> createState() => _WeeklyLetterBannerState();
}

class _WeeklyLetterBannerState extends State<WeeklyLetterBanner>
    with SingleTickerProviderStateMixin {
  bool _dismissed = false;
  late final AnimationController _dismissController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _dismissController.reverse().then((_) {
      if (mounted) setState(() => _dismissed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return BlocBuilder<WeeklyLetterCubit, WeeklyLetterState>(
      builder: (context, state) {
        if (state is WeeklyLetterLoading) {
          return WeeklyLetterShell(
            fadeAnimation: _fadeAnim,
            onDismissed: () => setState(() => _dismissed = true),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
              child: Center(
                child: Lottie.asset(
                  AppAssets.lottiePlantSprout,
                  width: 24.w,
                  height: 24.h,
                  repeat: true,
                ),
              ),
            ),
          );
        }

        if (state is! WeeklyLetterLoaded) return const SizedBox.shrink();

        return WeeklyLetterShell(
          fadeAnimation: _fadeAnim,
          onDismissed: () => setState(() => _dismissed = true),
          child: WeeklyLetterContent(data: state.data, onDismiss: _dismiss),
        );
      },
    );
  }
}
