import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur_app/core/constants/app_spacing.dart';
import 'package:lueur_app/core/injection/injection.dart';
import 'package:lueur_app/core/navigation/app_bottom_nav_bar.dart';
import 'package:lueur_app/core/routing/app_routes.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';
import 'package:lueur_app/core/widgets/app_blob_background.dart';
import 'package:lueur_app/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur_app/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur_app/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur_app/features/response/presentation/widgets/action_buttons_widget.dart';
import 'package:lueur_app/features/response/presentation/widgets/after_feeling_selector_widget.dart';
import 'package:lueur_app/features/response/presentation/widgets/ai_response_card_widget.dart';
import 'package:lueur_app/features/response/presentation/widgets/luna_avatar_widget.dart';
import 'package:lueur_app/features/response/presentation/widgets/luna_info_widget.dart';
import 'package:lueur_app/features/response/presentation/widgets/mood_tags_row_widget.dart';
import 'package:lueur_app/features/response/presentation/widgets/user_mood_card_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
              // ── App Bar ─────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPaddingMd,
                  vertical: AppSpacing.verticalPaddingSm,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
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
                        'Luna\'s Response',
                        style: ThemeTextStyles.headlineSmall(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 40.w),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────
              Expanded(
                child: BlocListener<MoodCubit, MoodState>(
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
                  child: BlocBuilder<MoodCubit, MoodState>(
                    builder: (context, state) {
                      if (state is MoodLoading) {
                        return const Center(child: LunaTypingIndicator());
                      }

                      if (state is MoodError) {
                        return Center(
                          child: Padding(
                            padding:
                                EdgeInsets.all(AppSpacing.horizontalPaddingLg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.errorColor,
                                  size: 48,
                                ),
                                SizedBox(height: AppSpacing.spaceMd),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: ThemeTextStyles.bodyMedium(context),
                                ),
                                SizedBox(height: AppSpacing.spaceLg),
                                ElevatedButton(
                                  onPressed: () {
                                    if (widget.emojiUnicode != null) {
                                      _didResponseHaptic = false;
                                      context
                                          .read<MoodCubit>()
                                          .generateResponse(
                                            emoji: widget.emojiUnicode!,
                                            thoughts: widget.thoughts,
                                          );
                                    }
                                  },
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Success or initial (show content)
                      final generated = state is MoodHistorySuccess
                          ? state.justGenerated
                          : null;
                      final aiResponse = generated?.aiResponse ?? '';
                      final displayThoughts =
                          generated?.thoughts ?? widget.thoughts;

                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.horizontalPaddingLg,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: AppSpacing.spaceLg),
                            const LunaAvatarWidget(),
                            SizedBox(height: AppSpacing.spaceMd),
                            const LunaInfoWidget(),
                            SizedBox(height: AppSpacing.sectionSpacingMd),
                            UserMoodCardWidget(
                              emoji: widget.emojiImagePath ??
                                  widget.emojiUnicode ??
                                  '😔',
                              thoughts: displayThoughts,
                              isEmojiImage: widget.emojiImagePath != null,
                            ),
                            SizedBox(height: AppSpacing.spaceLg),
                            if (aiResponse.isNotEmpty) ...[
                              AiResponseCardWidget(
                                response: aiResponse,
                                onBookmark: () {
                                  context.read<SavedQuotesCubit>().saveQuote(
                                        aiResponse,
                                        emoji: widget.emojiImagePath ??
                                            widget.emojiUnicode,
                                        thoughts: displayThoughts,
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Saved to quotes 🌿'),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: AppSpacing.spaceLg),
                              const MoodTagsRowWidget(
                                tags: ['Expressing', 'Reflecting', 'Growing'],
                              ),
                              SizedBox(height: AppSpacing.sectionSpacingMd),
                              ActionButtonsWidget(
                                saveLabel: 'Done',
                                talkAgainLabel: 'Keep chatting',
                                onSave: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(AppRoutes.home);
                                  }
                                },
                                onTalkAgain: aiResponse.isNotEmpty
                                    ? () {
                                        context.push(
                                          AppRoutes.chat,
                                          extra: {
                                            'userId': sl<FirebaseAuth>()
                                                    .currentUser
                                                    ?.uid ??
                                                '',
                                            'emoji':
                                                widget.emojiUnicode ?? '😊',
                                            'thoughts': displayThoughts,
                                            'aiResponse': aiResponse,
                                          },
                                        );
                                      }
                                    : null,
                              ),
                              SizedBox(height: AppSpacing.spaceMd),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _shareResponse(aiResponse),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSpacing.spaceLg,
                                    ),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Share',
                                    style: ThemeTextStyles.labelMedium(context)
                                        .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpacing.spaceLg),
                              const AfterFeelingSelectorWidget(),
                              SizedBox(height: AppSpacing.sectionSpacingMd),
                            ],
                          ],
                        ),
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

extension _ShareHelper on _ResponseAiScreenState {
  Future<void> _shareResponse(String aiResponse) async {
    if (aiResponse.trim().isEmpty) return;

    // Capture render box and build share card before any awaits
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
    final shareCard = _buildShareCard(context, aiResponse);

    final bytes = await _screenshotController.captureFromWidget(
      shareCard,
      pixelRatio: 3.0,
    );

    if (!mounted) return;

    final file = File(
      '${Directory.systemTemp.path}/luna_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);

    if (!mounted) return;

    await Share.shareXFiles(
      [XFile(file.path)],
      sharePositionOrigin: origin,
    );
  }

  Widget _buildShareCard(BuildContext context, String aiResponse) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Container(
        width: 1080,
        padding: const EdgeInsets.all(64),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.12),
              theme.colorScheme.primary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Luna says',
              style: ThemeTextStyles.labelMedium(context).copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '"$aiResponse"',
              style: ThemeTextStyles.headlineSmall(context).copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'MindEase · LunaTree',
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LunaTypingIndicator extends StatefulWidget {
  const LunaTypingIndicator({super.key});

  @override
  State<LunaTypingIndicator> createState() => _LunaTypingIndicatorState();
}

class _LunaTypingIndicatorState extends State<LunaTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = ThemeTextStyles.bodyMedium(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final dot1 = value < 0.33 ? 1.0 : 0.3;
        final dot2 = value >= 0.33 && value < 0.66 ? 1.0 : 0.3;
        final dot3 = value >= 0.66 ? 1.0 : 0.3;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Luna is thinking', style: textStyle),
            SizedBox(height: AppSpacing.spaceSm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(opacity: dot1),
                SizedBox(width: AppSpacing.spaceSm),
                _Dot(opacity: dot2),
                SizedBox(width: AppSpacing.spaceSm),
                _Dot(opacity: dot3),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: const Text('●'),
    );
  }
}
