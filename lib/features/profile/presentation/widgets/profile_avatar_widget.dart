import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/initials_avatar.dart';

/// Initials avatar with name and joined subtitle
class ProfileAvatarWidget extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? seed;

  const ProfileAvatarWidget({
    super.key,
    required this.name,
    required this.subtitle,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InitialsAvatar(diameter: 88.w, name: name, seed: seed),
        SizedBox(height: AppSpacing.spaceLg),

        // Name
        Text(name, style: ThemeTextStyles.headlineSmall(context)),
        SizedBox(height: AppSpacing.spaceXs),

        // Subtitle
        Text(subtitle, style: ThemeTextStyles.bodySmall(context)),
      ],
    );
  }
}
