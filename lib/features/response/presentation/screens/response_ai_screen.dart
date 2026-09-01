import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/navigation/app_bottom_nav_bar.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/widgets/app_blob_background.dart';
import 'package:lueur/core/widgets/offline_snackbar.dart';
import 'package:lueur/core/widgets/response_error_state.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/response/presentation/utils/response_sharer.dart';
import 'package:lueur/features/response/presentation/widgets/luna_typing_indicator.dart';
import 'package:lueur/features/response/presentation/widgets/response_app_bar.dart';
import 'package:lueur/features/response/presentation/widgets/response_success_content.dart';
import 'package:lueur/l10n/app_localizations.dart';
import 'package:screenshot/screenshot.dart';

class ResponseAiScreen extends StatefulWidget {
  const ResponseAiScreen({
    super.key,
    this.emojiImagePath,
    this.emojiUnicode,
    this.thoughts = '',
  });

  final String? emojiImagePath;
  final String? emojiUnicode;
  final String thoughts;

  @override
  State<ResponseAiScreen> createState() => _ResponseAiScreenState();
}

class _ResponseAiScreenState extends State<ResponseAiScreen> {
  bool _didResponseHaptic = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    if (widget.emojiUnicode != null && widget.thoughts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MoodCubit>().generateResponse(
                emoji: widget.emojiUnicode!,
                thoughts: widget.thoughts,
              );
        }
      });
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _retryGenerate() {
    if (widget.emojiUnicode == null) return;
    _didResponseHaptic = false;
    context.read<MoodCubit>().generateResponse(
          emoji: widget.emojiUnicode!,
          thoughts: widget.thoughts,
        );
  }

  void _bookmarkResponse(String aiResponse, String displayThoughts) {
    context.read<SavedQuotesCubit>().saveQuote(
          aiResponse,
          emoji: widget.emojiImagePath ?? widget.emojiUnicode,
          thoughts: displayThoughts,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.commonSavedToQuotesSnack),
      ),
    );
  }

  void _talkAgain(String aiResponse, String displayThoughts) {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    context.push(
      AppRoutes.chat,
      extra: {
        'userId': userId,
        'emoji': widget.emojiUnicode ?? '😊',
        'thoughts': displayThoughts,
        'aiResponse': aiResponse,
      },
    );
  }

  Future<void> _share(String aiResponse) => shareResponseCard(
        context,
        screenshotController: _screenshotController,
        aiResponse: aiResponse,
        isMounted: () => mounted,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go(AppRoutes.home);
          if (index == 1) context.go(AppRoutes.journal);
          if (index == 2) context.go(AppRoutes.profile);
        },
      ),
      body: AppBlobBackground(
        child: SafeArea(
          child: Column(
            children: [
              ResponseAppBar(
                title: AppLocalizations.of(context)!.responseScreenTitle,
                onBack: _goBack,
              ),
              Expanded(
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<MoodCubit, MoodState>(
                      listenWhen: (previous, current) {
                        if (_didResponseHaptic) return false;
                        return current is MoodHistorySuccess &&
                            current.justGenerated != null &&
                            current.justGenerated!.aiResponse.isNotEmpty;
                      },
                      listener: (context, state) {
                        HapticFeedback.lightImpact();
                        _didResponseHaptic = true;
                      },
                    ),
                    BlocListener<MoodCubit, MoodState>(
                      listenWhen: (previous, current) =>
                          current is MoodError && current.offline,
                      listener: (context, state) => showOfflineSnackBar(context),
                    ),
                  ],
                  child: BlocBuilder<MoodCubit, MoodState>(
                    builder: (context, state) {
                      if (state is MoodLoading) {
                        return const Center(child: LunaTypingIndicator());
                      }

                      if (state is MoodError && state.offline) {
                        return Center(
                          child: TextButton.icon(
                            onPressed: _retryGenerate,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              AppLocalizations.of(context)!.responseTryAgainButton,
                            ),
                          ),
                        );
                      }

                      if (state is MoodError) {
                        return ResponseErrorState(
                          message: AppLocalizations.of(context)!
                              .responseGenericErrorMessage,
                          retryLabel:
                              AppLocalizations.of(context)!.responseTryAgainButton,
                          onRetry: _retryGenerate,
                        );
                      }

                      final generated = state is MoodHistorySuccess
                          ? state.justGenerated
                          : null;
                      final aiResponse = generated?.aiResponse ?? '';
                      final displayThoughts =
                          generated?.thoughts ?? widget.thoughts;

                      return ResponseSuccessContent(
                        emojiImagePath: widget.emojiImagePath,
                        emojiUnicode: widget.emojiUnicode,
                        displayThoughts: displayThoughts,
                        aiResponse: aiResponse,
                        onBookmark: () =>
                            _bookmarkResponse(aiResponse, displayThoughts),
                        onDone: _goBack,
                        onTalkAgain: aiResponse.isNotEmpty
                            ? () => _talkAgain(aiResponse, displayThoughts)
                            : null,
                        onShare: () => _share(aiResponse),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
