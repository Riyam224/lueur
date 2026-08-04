import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Back button + centered title row at the top of the response screen.
class ResponseAppBar extends StatelessWidget {
  const ResponseAppBar({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingMd,
        vertical: AppSpacing.verticalPaddingSm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.extra.cardBackgroundColor,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: context.extra.primaryTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: ThemeTextStyles.headlineSmall(context),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }
}
