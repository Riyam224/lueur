import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// A soft, single fade-in check-in from Luna shown once an exercise
/// (breathing or affirmations) is fully done. Never shown mid-exercise —
/// only at the completion moment, offering to keep talking or head home.
class LunaCheckInPrompt extends StatefulWidget {
  final VoidCallback onTalkToLuna;
  final VoidCallback onDismiss;

  const LunaCheckInPrompt({
    super.key,
    required this.onTalkToLuna,
    required this.onDismiss,
  });

  @override
  State<LunaCheckInPrompt> createState() => _LunaCheckInPromptState();
}

class _LunaCheckInPromptState extends State<LunaCheckInPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.space2Xl),
        decoration: BoxDecoration(
          color: context.extra.cardBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: context.extra.borderColor ?? AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lavender.withValues(alpha: 0.2),
              ),
              child: Image.asset(
                AppAssets.lunaCharacter,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppSpacing.spaceMd),
            Text(
              'Feel a little lighter?',
              style: ThemeTextStyles.headlineSmall(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spaceXs),
            Text(
              'I\'m here if you want to talk more.',
              style: ThemeTextStyles.bodyMedium(context).copyWith(
                color: context.extra.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spaceXl),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.space3Xl + AppSpacing.space2Xl,
              child: ElevatedButton(
                onPressed: widget.onTalkToLuna,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Talk to Luna',
                  style: ThemeTextStyles.whiteButton(context).copyWith(
                    color: AppColors.whiteTextColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.spaceMd),
            TextButton(
              onPressed: widget.onDismiss,
              child: Text(
                'I\'m good for now',
                style: ThemeTextStyles.bodyMedium(context).copyWith(
                  color: context.extra.secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
