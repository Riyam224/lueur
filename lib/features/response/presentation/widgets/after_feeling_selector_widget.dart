import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/response/presentation/models/after_feeling_option.dart';
import 'package:lueur/features/response/presentation/widgets/after_feeling_emoji_option.dart';
import 'package:lueur/features/response/presentation/widgets/after_feeling_mood_modal.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// After-feeling selector — tapping any emoji shows a floating modal.
class AfterFeelingSelectorWidget extends StatefulWidget {
  const AfterFeelingSelectorWidget({super.key});

  @override
  State<AfterFeelingSelectorWidget> createState() =>
      _AfterFeelingSelectorWidgetState();
}

class _AfterFeelingSelectorWidgetState
    extends State<AfterFeelingSelectorWidget> {
  int? _selectedIndex;

  static const int _negativeIndex = 3;

  List<AfterFeelingOption> get _feelings {
    final l10n = AppLocalizations.of(context)!;
    return [
      (
        asset: MoodType.calm.assetPath,
        label: l10n.afterFeelingCalmLabel,
        message: l10n.afterFeelingCalmMessage,
      ),
      (
        asset: MoodType.grateful.assetPath,
        label: l10n.afterFeelingLovedLabel,
        message: l10n.afterFeelingLovedMessage,
      ),
      (
        asset: MoodType.hopeful.assetPath,
        label: l10n.afterFeelingBetterLabel,
        message: l10n.afterFeelingBetterMessage,
      ),
      (
        asset: MoodType.sad.assetPath,
        label: l10n.afterFeelingStillSadLabel,
        message: l10n.afterFeelingStillSadMessage,
      ),
    ];
  }

  void _onSelect(int index) {
    final wasAlreadySelected = _selectedIndex == index;
    setState(() => _selectedIndex = wasAlreadySelected ? null : index);
    if (wasAlreadySelected) return;
    _showMoodModal(index);
  }

  void _showMoodModal(int index) {
    final feeling = _feelings[index];
    final isNegative = index == _negativeIndex;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppLocalizations.of(context)!.commonDismissBarrierLabel,
      barrierColor: AppColors.overlayBlack.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (_, anim, __, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, __) => AfterFeelingMoodModal(
        asset: feeling.asset,
        label: feeling.label,
        message: feeling.message,
        isNegative: isNegative,
        onTalkAgain: isNegative
            ? () {
                Navigator.of(ctx).pop();
                context.go(AppRoutes.home);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.space2Xl),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.afterFeelingPromptLabel,
            style: ThemeTextStyles.titleSmall(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.spaceLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _feelings.length,
              (index) => AfterFeelingEmojiOption(
                asset: _feelings[index].asset,
                label: _feelings[index].label,
                isSelected: _selectedIndex == index,
                onTap: () => _onSelect(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
