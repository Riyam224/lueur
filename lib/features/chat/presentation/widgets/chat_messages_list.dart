import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';
import 'package:lueur/features/chat/presentation/utils/chat_message_content.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_empty_state.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_message_bubble_row.dart';

/// Scrollable transcript of the current chat session, or [ChatEmptyState]
/// when there are no messages yet.
class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({
    super.key,
    required this.scrollController,
    required this.state,
    required this.onBookmarkMessage,
  });

  final ScrollController scrollController;
  final ChatState state;
  final void Function(int index) onBookmarkMessage;

  @override
  Widget build(BuildContext context) {
    if (state.messages.isEmpty) return const ChatEmptyState();

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingMd,
        vertical: AppSpacing.verticalPaddingSm,
      ),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isUser = message.role == 'user';
        final isPreviousSameRole =
            index > 0 && state.messages[index - 1].role == message.role;

        return ChatMessageBubbleRow(
          content: resolveChatMessageContent(context, message),
          isUser: isUser,
          isFirst: index == 0,
          isPreviousSameRole: isPreviousSameRole,
          onBookmark: isUser ? null : () => onBookmarkMessage(index),
        );
      },
    );
  }
}
