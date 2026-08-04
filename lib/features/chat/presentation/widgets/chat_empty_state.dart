import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Shown before the first message is sent in a chat session.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.lunaCharacter,
            width: 72.w,
            height: 72.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: AppSpacing.verticalPaddingSm),
          Text(
            AppLocalizations.of(context)!.chatEmptyStateMessage,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color: extra.secondaryTextColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
