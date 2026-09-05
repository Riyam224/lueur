import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/widgets/offline_snackbar.dart';
import 'package:lueur/core/widgets/response_guest_blocked_state.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_messages_list.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_session_end_card.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_typing_indicator.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String emoji;

  /// Thoughts carried over from a completed exercise, not yet sent to Luna —
  /// when present, sent automatically on open so the user needn't repeat themselves.
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
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatCubit>().sendMessage(
          emoji: widget.emoji,
          thoughts: text,
        );
    _scrollToBottom();
  }

  void _saveMessage(ChatState state, int index) {
    String? precedingThoughts;
    for (var i = index - 1; i >= 0; i--) {
      if (state.messages[i].role == ChatMessage.roleUser) {
        precedingThoughts = state.messages[i].content;
        break;
      }
    }

    context.read<SavedQuotesCubit>().saveQuote(
          state.messages[index].content,
          emoji: widget.emoji,
          thoughts: precedingThoughts,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.commonSavedToQuotesSnack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const ChatAppBar(),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.success) _scrollToBottom();
          if (state.offline) showOfflineSnackBar(context);
        },
        builder: (context, state) {
          if (state.guestBlocked) {
            return ResponseGuestBlockedState(
              onSignIn: () => context.go(AppRoutes.loginScreen),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ChatMessagesList(
                  scrollController: _scrollController,
                  state: state,
                  onBookmarkMessage: (index) => _saveMessage(state, index),
                ),
              ),
              if (state.status == ChatStatus.loading)
                const ChatTypingIndicator(),
              if (state.sessionEnded)
                ChatSessionEndCard(
                  onBackToHome: () {
                    context.read<ChatCubit>().resetSession();
                    Navigator.pop(context);
                  },
                )
              else
                ChatInputBar(
                  controller: _controller,
                  isLoading: state.status == ChatStatus.loading,
                  onSend: _sendMessage,
                ),
            ],
          );
        },
      ),
    );
  }
}
