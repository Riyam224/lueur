import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_bubble.dart';

/// One row in the chat transcript: Luna's avatar (only on the first message
/// of a consecutive group), the message bubble, and an optional bookmark
/// button for saving Luna's replies as quotes.
class ChatMessageBubbleRow extends StatelessWidget {
  const ChatMessageBubbleRow({
    super.key,
    required this.content,
    required this.isUser,
    required this.isFirst,
    required this.isPreviousSameRole,
    this.onBookmark,
  });

  final String content;
  final bool isUser;
  final bool isFirst;
  final bool isPreviousSameRole;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isPreviousSameRole ? 4.h : 12.h,
        top: isFirst ? 4.h : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            !isPreviousSameRole
                ? Container(
                    width: 28.w,
                    height: 28.h,
                    margin: EdgeInsets.only(
                      right: AppSpacing.spaceSm,
                      bottom: 2.h,
                    ),
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppAssets.lunaCharacter,
                      fit: BoxFit.contain,
                    ),
                  )
                : SizedBox(width: 36.w),
          Flexible(child: ChatBubble(content: content, isUser: isUser)),
          if (onBookmark != null)
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                Icons.bookmark_border_rounded,
                size: 18.sp,
                color: cs.primary.withValues(alpha: 0.6),
              ),
              padding: EdgeInsets.only(left: 4.w),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
