import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_banner.dart';
import 'package:lueur/l10n/app_localizations.dart';

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
                      AppLocalizations.of(context)!.weeklyLetterScreenTitle,
                      style: ThemeTextStyles.headlineSmall(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 40.w),
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
