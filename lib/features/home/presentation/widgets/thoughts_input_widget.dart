import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

class ThoughtsInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const ThoughtsInputWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  static const int _maxThoughtsLines = 5;
  static const int _maxThoughtsLength = 500;

  static const int _encouragementStartThreshold = 50;
  static const int _encouragementContinueThreshold = 150;
  static const int _encouragementOpeningUpThreshold = 300;
  static const int _encouragementBeautifulThreshold = 450;

  @override
  Widget build(BuildContext context) {
    final extraColors = context.extra;

    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: _maxThoughtsLines,
          maxLength: _maxThoughtsLength,
          style: ThemeTextStyles.bodyMedium(context),
          decoration: InputDecoration(
            filled: true,
            fillColor: extraColors.cardBackgroundColor,
            hintText: AppLocalizations.of(context)!.homeThoughtsHint,
            hintStyle: ThemeTextStyles.bodySmall(context),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: extraColors.primaryColor!,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: extraColors.primaryColor!,
                width: 2.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: extraColors.borderColor!,
                width: 1.w,
              ),
            ),
            contentPadding: EdgeInsets.all(AppSpacing.horizontalPaddingMd),
          ),
        ),
        SizedBox(height: AppSpacing.spaceSm),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final count = value.text.trim().length;
            return Text(
              _encouragementForCount(context, count),
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: extraColors.secondaryTextColor,
              ),
              textAlign: TextAlign.left,
            );
          },
        ),
        SizedBox(height: AppSpacing.spaceLg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: extraColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingXl,
                vertical: AppSpacing.verticalPaddingLg,
              ),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.commonTalkToLuna,
              style: ThemeTextStyles.whiteButton(context),
            ),
          ),
        ),
      ],
    );
  }

  String _encouragementForCount(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context)!;
    if (count < _encouragementStartThreshold) {
      return l10n.homeThoughtsEncouragementStart;
    }
    if (count < _encouragementContinueThreshold) {
      return l10n.homeThoughtsEncouragementContinue;
    }
    if (count < _encouragementOpeningUpThreshold) {
      return l10n.homeThoughtsEncouragementOpeningUp;
    }
    if (count < _encouragementBeautifulThreshold) {
      return l10n.homeThoughtsEncouragementBeautiful;
    }
    return l10n.homeThoughtsEncouragementListening;
  }
}
