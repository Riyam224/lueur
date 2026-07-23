import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_choice_destination.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Floating "rough day, huh?" chooser shown when the user logs a low mood —
/// lets them pick how they'd like to feel better before Luna sends them on
/// to an uplifting affirmation card and then their choice.
Future<void> showMoodChoiceDialog(
  BuildContext context, {
  required String emoji,
  required String thoughts,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    pageBuilder: (dialogContext, _, __) => _MoodChoiceDialog(
      emoji: emoji,
      thoughts: thoughts,
    ),
  );
}

class _MoodChoiceDialog extends StatelessWidget {
  final String emoji;
  final String thoughts;

  const _MoodChoiceDialog({required this.emoji, required this.thoughts});

  void _choose(BuildContext context, MoodChoiceDestination destination) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    context.push(
      AppRoutes.affirmation,
      extra: {
        'emoji': emoji,
        'thoughts': thoughts,
        'destination': destination.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingXl,
          ),
          padding: EdgeInsets.all(AppSpacing.space2Xl),
          decoration: BoxDecoration(
            color: context.extra.cardBackgroundColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: (context.extra.shadowColor ?? Colors.black)
                    .withValues(alpha: 0.15),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'rough day, huh?',
                style: ThemeTextStyles.bodySmall(context).copyWith(
                  color: context.extra.secondaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: AppSpacing.spaceXs),
              Text(
                'whatever feels right right now',
                style: ThemeTextStyles.editorialHeadline(context, fontSize: 20),
              ),
              SizedBox(height: AppSpacing.spaceXl),
              _MoodChoiceCard(
                title: 'Talk to Luna',
                subtitle: 'share what\'s on your mind',
                icon: Icons.chat_bubble_rounded,
                glowColor: AppColors.lavender,
                onTap: () => _choose(context, MoodChoiceDestination.talkToLuna),
              ),
              SizedBox(height: AppSpacing.spaceMd),
              _MoodChoiceCard(
                title: 'Free Draw',
                subtitle: 'no pressure, just color',
                icon: Icons.brush_rounded,
                glowColor: AppColors.accent,
                onTap: () => _choose(context, MoodChoiceDestination.freeDraw),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodChoiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  const _MoodChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_MoodChoiceCard> createState() => _MoodChoiceCardState();
}

class _MoodChoiceCardState extends State<_MoodChoiceCard> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.spaceLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.extra.borderColor ?? AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.glowColor.withValues(alpha: 0.2),
                ),
                child: Icon(widget.icon, color: widget.glowColor, size: 20),
              ),
              SizedBox(width: AppSpacing.spaceLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: ThemeTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: ThemeTextStyles.bodySmall(context).copyWith(
                        color: context.extra.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.extra.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
