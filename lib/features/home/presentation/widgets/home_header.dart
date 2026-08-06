import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/initials_avatar.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/presentation/cubit/theme_cubit.dart';

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
        InitialsAvatar(
          diameter: AppSizes.avatarSm,
          name: userName,
          seed: userSeed,
        ),

        BlocBuilder<ThemeCubit, ThemeModeOption>(
          builder: (context, themeModeOption) {
            final platformBrightness = MediaQuery.platformBrightnessOf(
              context,
            );
            final isDark = themeModeOption == ThemeModeOption.dark ||
                (themeModeOption == ThemeModeOption.system &&
                    platformBrightness == Brightness.dark);
            return IconButton(
              onPressed: () {
                context.read<ThemeCubit>().setThemeMode(
                      isDark ? ThemeModeOption.light : ThemeModeOption.dark,
                    );
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
