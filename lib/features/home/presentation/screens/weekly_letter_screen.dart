import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/widgets/app_top_bar.dart';
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
      appBar: AppTopBar(
        title: AppLocalizations.of(context)!.weeklyLetterScreenTitle,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sectionSpacingMd),
              const WeeklyLetterBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
