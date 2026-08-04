import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/presentation/cubit/theme_cubit.dart';

/// Three-option Light / Dark / System segmented control for the Settings
/// screen, following the same visual pattern as [LanguageToggleWidget].
class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = context.watch<ThemeCubit>().state;

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            tooltip: 'Light',
            selected: currentMode == ThemeModeOption.light,
            onTap: () => context
                .read<ThemeCubit>()
                .setThemeMode(ThemeModeOption.light),
          ),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            tooltip: 'Dark',
            selected: currentMode == ThemeModeOption.dark,
            onTap: () =>
                context.read<ThemeCubit>().setThemeMode(ThemeModeOption.dark),
          ),
          _ThemeOption(
            icon: Icons.brightness_auto_rounded,
            tooltip: 'System',
            selected: currentMode == ThemeModeOption.system,
            onTap: () => context
                .read<ThemeCubit>()
                .setThemeMode(ThemeModeOption.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSm,
            color: selected ? cs.onPrimary : null,
          ),
        ),
      ),
    );
  }
}
