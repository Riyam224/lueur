import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur_app/core/cubits/theme_cubit.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';

/// SETTINGS section with all setting rows
class ProfileSettingsSectionWidget extends StatelessWidget {
  const ProfileSettingsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          'SETTINGS',
          style: ThemeTextStyles.labelSmall(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),

        // Appearance (dark mode toggle)
        _SettingsItem(
          icon: Icons.dark_mode_rounded,
          iconColor: context.extra.settingsModeIconColor!,
          iconBgColor: context.extra.settingsModeIconBg!,
          label: 'Appearance',
          trailing: Switch(
            value: isDark,
            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ),

        _divider(context),

        _SettingsItem(
          icon: Icons.auto_awesome_rounded,
          iconColor: context.extra.settingsAboutIconColor!,
          iconBgColor: context.extra.settingsAboutIconBg!,
          label: 'About Luna',
          trailing: _chevron(context),
          onTap: () {},
        ),

        _divider(context),

        _SettingsItem(
          icon: Icons.privacy_tip_rounded,
          iconColor: context.extra.settingsPrivacyIconColor!,
          iconBgColor: context.extra.settingsPrivacyIconBg!,
          label: 'Privacy Policy',
          trailing: _chevron(context),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Divider(
        height: 1,
        thickness: 0.5,
        color: context.extra.borderColor,
      );

  Widget _chevron(BuildContext context) => Icon(
        Icons.chevron_right_rounded,
        color: context.extra.tertiaryTextColor,
        size: 20,
      );
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.trailing,
    this.onTap,
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
            // Icon in colored soft circle
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

            // Label
            Expanded(
              child: Text(label, style: ThemeTextStyles.bodyLarge(context)),
            ),

            trailing,
          ],
        ),
      ),
    );
  }
}
