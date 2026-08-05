import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Glassy, floating pill-shaped bottom navigation bar
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.home_outlined,   activeIcon: Icons.home_rounded),
    (icon: Icons.book_outlined,   activeIcon: Icons.book_rounded),
    (icon: Icons.person_outlined, activeIcon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final extra = context.extra;
    final primary = extra.primaryColor!;
    final secondaryText = extra.secondaryTextColor!;
    final cardBackground = extra.cardBackgroundColor!;
    final borderColor = extra.borderColor!;
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.navHomeLabel,
      l10n.navJournalLabel,
      l10n.navProfileLabel,
    ];

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.overlayBlack : primary).withValues(
                alpha: isDark ? 0.35 : 0.18,
              ),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? primary.withValues(alpha: 0.22)
                    : cardBackground.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: borderColor.withValues(alpha: isDark ? 0.35 : 0.80),
                  width: 0.8,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  children: List.generate(
                    _items.length,
                    (i) => Expanded(
                      child: _NavItem(
                        icon: _items[i].icon,
                        activeIcon: _items[i].activeIcon,
                        label: labels[i],
                        isActive: currentIndex == i,
                        activeColor: primary,
                        inactiveColor: secondaryText,
                        onTap: () => onTap(i),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.88,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.13)
              : activeColor.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isActive ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 320),
              curve: Curves.elasticOut,
              builder: (context, hop, child) => Transform.translate(
                offset: Offset(0, -3.h * hop),
                child: child,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? activeColor : inactiveColor,
                size: 22.sp,
              ),
            ),
            SizedBox(height: 3.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: ThemeTextStyles.navLabel(
                  context,
                  isActive: isActive,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isActive ? 5.w : 0,
              height: isActive ? 5.h : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
