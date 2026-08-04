import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Bottom text field + send button for composing a chat message.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: (extra.shadowColor ?? AppColors.overlayBlack)
                .withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: ThemeTextStyles.bodyMedium(context).copyWith(
                color: extra.primaryTextColor,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.chatInputHint,
                hintStyle: ThemeTextStyles.bodySmall(context).copyWith(
                  color: extra.secondaryTextColor,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPaddingMd,
                  vertical: AppSpacing.verticalPaddingSm,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          BouncyTap(
            onTap: isLoading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.primaryButtonFill.withValues(alpha: 0.4)
                    : AppColors.primaryButtonFill,
                shape: BoxShape.circle,
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: AppColors.whiteTextColor,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
