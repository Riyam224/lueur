// lib/features/chat/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Resolves a chat message's displayed text, mapping `ChatCubit`'s
/// send-failure sentinel (see [ChatMessage.sendFailedSentinelPrefix]) to the
/// matching localized string here, where a [BuildContext] is available.
String _resolveMessageContent(BuildContext context, ChatMessage message) {
  if (!message.isSendFailedSentinel) return message.content;
  final l10n = AppLocalizations.of(context)!;
  return switch (message.sendFailedSentinelIndex) {
    0 => l10n.chatSendFailedMessages0,
    1 => l10n.chatSendFailedMessages1,
    2 => l10n.chatSendFailedMessages2,
    3 => l10n.chatSendFailedMessages3,
    _ => l10n.chatSendFailedMessages4,
  };
}

class ChatScreen extends StatefulWidget {
  final String emoji;

  /// Thoughts carried over from a completed exercise (breathing /
  /// affirmations) that haven't been sent to Luna yet. When present, they're
  /// sent automatically on open so Luna's first reply already reflects what
  /// the user shared — no need to repeat themselves.
  final String? autoSendThoughts;

  const ChatScreen({
    super.key,
    required this.emoji,
    this.autoSendThoughts,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final autoThoughts = widget.autoSendThoughts;
    if (autoThoughts != null && autoThoughts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ChatCubit>().sendMessage(
                emoji: widget.emoji,
                thoughts: autoThoughts,
              );
        }
      });
    }
  }

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
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded,
            color: cs.primary, size: AppSizes.iconSm,),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppAssets.lunaCharacter,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: AppSpacing.spaceSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lunaName,
                style: ThemeTextStyles.labelMedium(context).copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                l10n.lunaName,
                style: ThemeTextStyles.labelSmall(context).copyWith(
                  color: extra.secondaryTextColor,
                  fontSize: 11.sp,
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

        return _buildMessageBubble(
          context: context,
          content: _resolveMessageContent(context, message),
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
      SnackBar(
        content: Text(AppLocalizations.of(context)!.commonSavedToQuotesSnack),
      ),
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
          // Luna avatar — only on first message in a group
          if (!isUser)
            !isPreviousSameRole
                ? Container(
                    width: 28.w,
                    height: 28.h,
                    margin: EdgeInsets.only(right: AppSpacing.spaceSm, bottom: 2.h),
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

          // Bubble
          Flexible(
            child: _ChatBubble(content: content, isUser: isUser),
          ),
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

  Widget _buildTypingIndicator(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: AppSpacing.spaceLg, bottom: AppSpacing.spaceSm),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: extra.cardBackgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: (extra.shadowColor ?? AppColors.overlayBlack)
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
              AppLocalizations.of(context)!.chatTypingLabel,
              style: ThemeTextStyles.labelSmall(context).copyWith(
                color: cs.primary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(width: 6.w),
            Image.asset(
              AppAssets.lunaCharacter,
              width: 22.w,
              height: 22.h,
              fit: BoxFit.contain,
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
              controller: _controller,
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
            onTap: isLoading ? null : () => _sendMessage(context),
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

  Widget _buildSessionEndCard(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.all(AppSpacing.spaceLg),
      padding: EdgeInsets.all(AppSpacing.space2Xl),
      decoration: BoxDecoration(
        color: extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: extra.borderColor ?? cs.outline),
        boxShadow: [
          BoxShadow(
            color: (extra.shadowColor ?? AppColors.overlayBlack)
                .withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🌿',
            style: TextStyle(
              fontSize: 32.sp,
              fontFamilyFallback: const ['Apple Color Emoji', 'Noto Color Emoji'],
            ),
          ),
          SizedBox(height: AppSpacing.spaceSm),
          Text(
            l10n.chatSessionEndGladMessage,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.headlineSmall(context).copyWith(
              color: cs.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.chatSessionEndSavedMessage,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.bodySmall(context).copyWith(
              color: extra.secondaryTextColor,
            ),
          ),
          SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ChatCubit>().resetSession();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonFill,
                foregroundColor: AppColors.whiteTextColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                l10n.chatBackToHomeButton,
                style: ThemeTextStyles.labelMedium(context).copyWith(
                  color: AppColors.whiteTextColor,
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

/// A single chat bubble with a light bounce-scale on tap — purely a tactile
/// touch, no navigation or side effect, so it stays a tiny self-contained
/// widget instead of triggering a rebuild of the whole message list.
class _ChatBubble extends StatefulWidget {
  final String content;
  final bool isUser;

  const _ChatBubble({required this.content, required this.isUser});

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  static const Curve _bounceBackCurve = Cubic(0.34, 1.56, 0.64, 1.0);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: Duration(milliseconds: _pressed ? 100 : 300),
        curve: _pressed ? Curves.easeOut : _bounceBackCurve,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingMd,
            vertical: AppSpacing.verticalPaddingSm,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          decoration: BoxDecoration(
            color: widget.isUser
                ? AppColors.primaryButtonFill
                : extra.cardBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(18.r),
              bottomLeft: Radius.circular(widget.isUser ? 18.r : 4.r),
              bottomRight: Radius.circular(widget.isUser ? 4.r : 18.r),
            ),
            boxShadow: [
              BoxShadow(
                color: (extra.shadowColor ?? AppColors.overlayBlack)
                    .withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.content,
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color: widget.isUser
                  ? AppColors.whiteTextColor
                  : extra.primaryTextColor,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
