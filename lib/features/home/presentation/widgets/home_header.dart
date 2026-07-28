import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/cubits/theme_cubit.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/initials_avatar.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Header with user avatar, app title, and theme toggle button
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.userName,
    super.key,
    this.userSeed,
  });

  final String userName;

  /// Stable identifier (user id/email) used to pick the avatar color.
  final String? userSeed;

  @override
  Widget build(BuildContext context) {
    final extraColors = context.extra;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Avatar
        InitialsAvatar(
          diameter: AppSizes.avatarSm,
          name: userName,
          seed: userSeed,
        ),

        // App Title
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.appName,
            overflow: TextOverflow.ellipsis,
            style: ThemeTextStyles.headlineSmall(context),
          ),
        ),

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
