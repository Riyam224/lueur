import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Purple avatar circle with initial, name and joined subtitle
class ProfileAvatarWidget extends StatelessWidget {
  final String name;
  final String subtitle;

  const ProfileAvatarWidget({
    super.key,
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Column(
      children: [
        // Avatar circle
        Container(
          width: 88.w,
          height: 88.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: extra.primaryColor,
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.mainFontName,
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: extra.onPrimaryTextColor,
              ),
            ),
          ),
        ),
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
