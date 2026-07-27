import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_banner.dart';

/// Full-screen home for the weekly letter, reached from Profile. Reuses
/// [WeeklyLetterBanner] as-is instead of duplicating its content/cubit wiring.
class WeeklyLetterScreen extends StatelessWidget {
  const WeeklyLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.weeklyLetterScreenTitle,
                      style: ThemeTextStyles.headlineSmall(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              SizedBox(height: AppSpacing.sectionSpacingMd),
              const WeeklyLetterBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
