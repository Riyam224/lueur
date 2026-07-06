import 'dart:ui';

import 'package:ai_therapist_app/core/styling/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Glass-skin bottom navigation bar
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.home_outlined,   activeIcon: Icons.home_rounded,    label: 'Home'),
    (icon: Icons.book_outlined,   activeIcon: Icons.book_rounded,    label: 'Journal'),
    (icon: Icons.person_outlined, activeIcon: Icons.person_rounded,  label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final extra = context.extra;
    final primary = extra.primaryColor!;
    final secondaryText = extra.secondaryTextColor!;
    final cardBackground = extra.cardBackgroundColor!;
    final borderColor = extra.borderColor!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? primary.withValues(alpha: 0.18)
                : cardBackground.withValues(alpha: 0.60),
            border: Border(
              top: BorderSide(
                color: borderColor.withValues(alpha: isDark ? 0.35 : 0.80),
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _items.length,
                  (i) => _NavItem(
                    icon: _items[i].icon,
                    activeIcon: _items[i].activeIcon,
                    label: _items[i].label,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22.sp,
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            SizedBox(height: 3.h),
            // Active dot
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
