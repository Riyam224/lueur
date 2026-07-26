import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Shortcuts to the Weekly Letter and the mood board (the existing Journal
/// feature, reused rather than duplicated).
class ProfileQuickLinksWidget extends StatelessWidget {
  const ProfileQuickLinksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuickLinkItem(
          icon: Icons.mail_outline_rounded,
          iconColor: context.extra.settingsAboutIconColor!,
          iconBgColor: context.extra.settingsAboutIconBg!,
          label: 'Weekly Letter',
          onTap: () => context.push(AppRoutes.weeklyLetter),
        ),
        Divider(height: 1, thickness: 0.5, color: context.extra.borderColor),
        _QuickLinkItem(
          icon: Icons.grid_view_rounded,
          iconColor: context.extra.settingsPrivacyIconColor!,
          iconBgColor: context.extra.settingsPrivacyIconBg!,
          label: 'Mood Board',
          onTap: () => context.go(AppRoutes.journal),
        ),
      ],
    );
  }
}

class _QuickLinkItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(label, style: ThemeTextStyles.bodyLarge(context)),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.extra.tertiaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
