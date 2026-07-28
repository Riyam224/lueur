import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/cubits/theme_cubit.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/language/presentation/widgets/language_toggle_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// SETTINGS section with all setting rows
class ProfileSettingsSectionWidget extends StatelessWidget {
  const ProfileSettingsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          l10n.profileSettingsSectionLabel,
          style: ThemeTextStyles.labelSmall(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.verticalPaddingSm),

        // Appearance (dark mode toggle)
        _SettingsItem(
          icon: Icons.dark_mode_rounded,
          iconColor: context.extra.settingsModeIconColor!,
          iconBgColor: context.extra.settingsModeIconBg!,
          label: l10n.profileSettingsAppearance,
          trailing: Switch(
            value: isDark,
            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ),

        // Language (English / Arabic toggle)
        _SettingsItem(
          icon: Icons.language_rounded,
          iconColor: context.extra.settingsModeIconColor!,
          iconBgColor: context.extra.settingsModeIconBg!,
          label: l10n.profileSettingsLanguage,
          trailing: const LanguageToggleWidget(),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final Widget trailing;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
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
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
              ),
              child: Icon(icon, color: iconColor, size: AppSizes.iconSm),
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
