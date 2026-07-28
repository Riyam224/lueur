// lib/features/affirmation/presentation/screens/affirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_choice_destination.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/luna_check_in_prompt.dart';
import 'package:lueur/features/affirmation/data/affirmations_data.dart';
import 'package:lueur/l10n/app_localizations.dart';

class AffirmationScreen extends StatefulWidget {
  final String emoji;
  final String thoughts;
  final MoodChoiceDestination destination;

  const AffirmationScreen({
    super.key,
    required this.emoji,
    this.thoughts = '',
    this.destination = MoodChoiceDestination.talkToLuna,
  });

  @override
  State<AffirmationScreen> createState() => _AffirmationScreenState();
}

class _AffirmationScreenState extends State<AffirmationScreen> {
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  List<String> get _cards =>
      affirmations[widget.emoji] ?? defaultAffirmations;

  String get _currentCard => _cards[_index.value];

  void _nextCard() {
    HapticFeedback.lightImpact();
    _index.value = (_index.value + 1) % _cards.length;
  }

  String _primaryLabel(BuildContext context) {
    switch (widget.destination) {
      case MoodChoiceDestination.talkToLuna:
        return AppLocalizations.of(context)!.commonTalkToLuna;
      case MoodChoiceDestination.breathing:
        return AppLocalizations.of(context)!.affirmationPrimaryStartBreathing;
      case MoodChoiceDestination.freeDraw:
        return AppLocalizations.of(context)!.affirmationPrimaryStartDrawing;
      case MoodChoiceDestination.sudoku:
        return AppLocalizations.of(context)!.affirmationPrimaryPlaySudoku;
    }
  }

  void _continue(BuildContext context) {
    switch (widget.destination) {
      case MoodChoiceDestination.talkToLuna:
        context.push(
          AppRoutes.response,
          extra: {
            'emojiPath': null,
            'emojiUnicode': widget.emoji,
            'thoughts': widget.thoughts,
          },
        );
      case MoodChoiceDestination.breathing:
        context.push(
          AppRoutes.breathing,
          extra: {'emoji': widget.emoji, 'thoughts': widget.thoughts},
        );
      case MoodChoiceDestination.freeDraw:
        context.push(
          AppRoutes.freeDraw,
          extra: {'emoji': widget.emoji, 'thoughts': widget.thoughts},
        );
      case MoodChoiceDestination.sudoku:
        context.push(
          AppRoutes.sudoku,
          extra: {'emoji': widget.emoji, 'thoughts': widget.thoughts},
        );
    }
  }

  @override
  void dispose() {
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingXl,
          ),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.space3Xl + AppSpacing.spaceSm),
              Text(
                AppLocalizations.of(context)!.affirmationHeader,
                style: ThemeTextStyles.headlineSmall(context).copyWith(
                  color: context.extra.primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.spaceSm),
              Text(
                AppLocalizations.of(context)!.affirmationSubheader,
                style: ThemeTextStyles.bodyMedium(context).copyWith(
                  color: context.extra.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.space3Xl + AppSpacing.spaceSm),
              ValueListenableBuilder<int>(
                valueListenable: _index,
                builder: (context, value, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Container(
                      key: ValueKey(value),
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.space2Xl),
                      decoration: BoxDecoration(
                        color: context.extra.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                        border: Border.all(
                          color: context.extra.borderColor ?? AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🌱',
                            style: ThemeTextStyles.headlineLarge(context),
                          ),
                          SizedBox(height: AppSpacing.spaceLg),
                          Text(
                            '"$_currentCard"',
                            style: ThemeTextStyles.bodyLarge(context).copyWith(
                              color: context.extra.primaryTextColor,
                              height: 1.7,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.spaceMd),
                          Text(
                            AppLocalizations.of(context)!.affirmationSignature,
                            style: ThemeTextStyles.labelSmall(context).copyWith(
                              color: context.extra.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.spaceXl),
              ValueListenableBuilder<int>(
                valueListenable: _index,
                builder: (context, value, child) {
                  return Text(
                    '${value + 1} / ${_cards.length}',
                    style: ThemeTextStyles.captionLarge(context).copyWith(
                      color: context.extra.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              SizedBox(height: AppSpacing.spaceXl),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.space3Xl + AppSpacing.spaceXl,
                child: OutlinedButton(
                  onPressed: _nextCard,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.spaceLg,
                    ),
                    side: BorderSide(
                      color: context.extra.borderColor ?? AppColors.cardBorder,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.affirmationNextCardButton,
                    style: ThemeTextStyles.labelMedium(context).copyWith(
                      color: context.extra.secondaryTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.spaceXl),
              LunaCheckInPrompt(
                primaryLabel: _primaryLabel(context),
                onTalkToLuna: () => _continue(context),
                onDismiss: () => context.go(AppRoutes.home),
              ),
              SizedBox(height: AppSpacing.space3Xl),
            ],
          ),
        ),
      ),
    );
  }
}
