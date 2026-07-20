import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

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

  static final List<({String asset, String label, String message})> _feelings =
      [
    (
      asset: MoodType.calm.assetPath,
      label: 'Calm',
      message: 'Feeling calm is a beautiful shift. You did great.',
    ),
    (
      asset: MoodType.grateful.assetPath,
      label: 'Loved',
      message: 'You deserve every bit of that love. Hold onto it.',
    ),
    (
      asset: MoodType.hopeful.assetPath,
      label: 'Better',
      message: 'Every small step forward counts. You are making progress.',
    ),
    (
      asset: MoodType.sad.assetPath,
      label: 'Still sad',
      message:
          'It\'s okay to still feel this way. Luna is always here whenever you need to talk again.',
    ),
  ];

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
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
      pageBuilder: (ctx, _, __) => _MoodModal(
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
            'How are you feeling after this?',
            style: ThemeTextStyles.titleSmall(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.spaceLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _feelings.length,
              (index) => _EmojiOption(
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

// ── Floating mood modal ───────────────────────────────────────────────────────

class _MoodModal extends StatelessWidget {
  final String asset;
  final String label;
  final String message;
  final bool isNegative;
  final VoidCallback? onTalkAgain;

  const _MoodModal({
    required this.asset,
    required this.label,
    required this.message,
    required this.isNegative,
    this.onTalkAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28.w),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji face — on dark mode wrap in a light circle so SVG fills show up
              Builder(builder: (context) {
                final isDark =
                    Theme.of(context).brightness == Brightness.dark;
                final img = asset.endsWith('.svg')
                    ? SvgPicture.asset(asset, width: 72.w, height: 72.h)
                    : Image.asset(asset, width: 72.w, height: 72.h);
                if (!isDark) return img;
                return Container(
                  width: 88.w,
                  height: 88.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.softLavender,
                  ),
                  alignment: Alignment.center,
                  child: img,
                );
              },),
              SizedBox(height: 16.h),

              // Feeling label
              Text(
                isNegative ? 'Take your time' : 'You are feeling $label',
                style: ThemeTextStyles.titleLarge(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              // Message
              Text(
                message,
                style: ThemeTextStyles.bodySmall(context)
                    .copyWith(height: 1.6),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),

              // Primary action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isNegative
                      ? onTalkAgain
                      : () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.whiteTextColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    isNegative ? 'Talk to Luna again' : 'Thank you, Luna',
                    style: ThemeTextStyles.labelMedium(context).copyWith(
                      color: AppColors.whiteTextColor,
                    ),
                  ),
                ),
              ),

              if (isNegative) ...[
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'I\'ll be okay',
                    style: ThemeTextStyles.bodySmall(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Emoji option button ───────────────────────────────────────────────────────

class _EmojiOption extends StatelessWidget {
  final String asset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiOption({
    required this.asset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 64.w,
        height: 72.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // No colorFilter — render SVG in its original colors
            asset.endsWith('.svg')
                ? SvgPicture.asset(
                    asset,
                    width: 36.w,
                    height: 36.h,
                  )
                : Image.asset(asset, width: 36.w, height: 36.h,
                    fit: BoxFit.contain,),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.mainFontName,
                fontSize: 10.sp,
                color: isSelected
                    ? AppColors.primary
                    : context.extra.secondaryTextColor!,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
