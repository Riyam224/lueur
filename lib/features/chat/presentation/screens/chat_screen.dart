// lib/features/chat/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';

class ChatScreen extends StatefulWidget {
  final String emoji;

  const ChatScreen({
    super.key,
    required this.emoji,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatCubit>().sendMessage(
          emoji: widget.emoji,
          thoughts: text,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.success) _scrollToBottom();
          if (state.status == ChatStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Something went wrong 🌿'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildMessagesList(context, state)),
              if (state.status == ChatStatus.loading)
                _buildTypingIndicator(context),
              if (state.sessionEnded)
                _buildSessionEndCard(context)
              else
                _buildInputBar(context, state),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded,
            color: cs.primary, size: 20,),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🌙',
                style: TextStyle(
                  fontSize: 18,
                  fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Luna',
                style: ThemeTextStyles.labelMedium(context).copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                'AI Therapist',
                style: ThemeTextStyles.labelSmall(context).copyWith(
                  color: extra.secondaryTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatState state) {
    if (state.messages.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isUser = message.role == 'user';
        final isPreviousSameRole =
            index > 0 && state.messages[index - 1].role == message.role;

        return _buildMessageBubble(
          context: context,
          content: message.content,
          isUser: isUser,
          isFirst: index == 0,
          isPreviousSameRole: isPreviousSameRole,
          onBookmark: isUser
              ? null
              : () => _saveMessage(context, state.messages, index),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final extra = context.extra;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🌙',
            style: TextStyle(
              fontSize: 48,
              fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Hi, I'm Luna 💜\nTell me how you're feeling.",
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

  void _saveMessage(BuildContext context, List<ChatMessage> messages, int index) {
    String? precedingThoughts;
    for (var i = index - 1; i >= 0; i--) {
      if (messages[i].role == 'user') {
        precedingThoughts = messages[i].content;
        break;
      }
    }

    context.read<SavedQuotesCubit>().saveQuote(
          messages[index].content,
          emoji: widget.emoji,
          thoughts: precedingThoughts,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to quotes 🌿')),
    );
  }

  Widget _buildMessageBubble({
    required BuildContext context,
    required String content,
    required bool isUser,
    required bool isFirst,
    required bool isPreviousSameRole,
    VoidCallback? onBookmark,
  }) {
    final cs = Theme.of(context).colorScheme;
    final extra = context.extra;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isPreviousSameRole ? 4 : 12,
        top: isFirst ? 4 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Luna avatar — only on first message in a group
          if (!isUser)
            !isPreviousSameRole
                ? Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 8, bottom: 2),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🌙',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamilyFallback: [
                            'Apple Color Emoji',
                            'Noto Color Emoji',
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: 36),

          // Bubble
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isUser ? cs.primary : extra.cardBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (extra.shadowColor ?? Colors.black)
                        .withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                content,
                style: ThemeTextStyles.bodyMedium(context).copyWith(
                  color: isUser
                      ? AppColors.whiteTextColor
                      : extra.primaryTextColor,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (onBookmark != null)
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                Icons.bookmark_border_rounded,
                size: 18,
                color: cs.primary.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.only(left: 4),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: extra.cardBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (extra.shadowColor ?? Colors.black)
                  .withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Luna is typing',
              style: ThemeTextStyles.labelSmall(context).copyWith(
                color: cs.primary,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '🌙',
              style: TextStyle(
                fontSize: 13,
                fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatState state) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;
    final isLoading = state.status == ChatStatus.loading;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: (extra.shadowColor ?? Colors.black)
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
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: ThemeTextStyles.bodyMedium(context).copyWith(
                color: extra.primaryTextColor,
              ),
              decoration: InputDecoration(
                hintText: 'Share what\'s on your mind...',
                hintStyle: ThemeTextStyles.bodySmall(context).copyWith(
                  color: extra.secondaryTextColor,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isLoading ? null : () => _sendMessage(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isLoading
                    ? cs.primary.withValues(alpha: 0.4)
                    : cs.primary,
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
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.whiteTextColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionEndCard(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: extra.borderColor ?? cs.outline),
        boxShadow: [
          BoxShadow(
            color: (extra.shadowColor ?? Colors.black)
                .withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🌿',
            style: TextStyle(
              fontSize: 32,
              fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "I'm glad you're feeling better 💜",
            textAlign: TextAlign.center,
            style: ThemeTextStyles.headlineSmall(context).copyWith(
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This session has been saved to your journal.',
            textAlign: TextAlign.center,
            style: ThemeTextStyles.bodySmall(context).copyWith(
              color: extra.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ChatCubit>().resetSession();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: AppColors.whiteTextColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Back to Home',
                style: ThemeTextStyles.labelMedium(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
