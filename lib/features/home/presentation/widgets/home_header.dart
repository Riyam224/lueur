import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/cubits/theme_cubit.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Header with user avatar, app title, and theme toggle button
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.userName,
    super.key,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final extraColors = context.extra;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Avatar
        Container(
          width: AppSizes.avatarSm,
          height: AppSizes.avatarSm,
          decoration: BoxDecoration(
            color: extraColors.primaryColor,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
          ),
          child: Center(
            child: Text(
              userName.substring(0, 1).toUpperCase(),
              style: ThemeTextStyles.whiteHeadline(context),
            ),
          ),
        ),

        // App Title
        Text('LunaTree', style: ThemeTextStyles.headlineSmall(context)),

        // Theme Toggle Button
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDark = themeMode == ThemeMode.dark;
            return IconButton(
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: extraColors.primaryColor,
                size: AppSizes.iconMd,
              ),
            );
          },
        ),
      ],
    );
  }
}
