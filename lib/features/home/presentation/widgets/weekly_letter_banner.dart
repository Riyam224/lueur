import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/styling/theme_extensions.dart';
import 'package:ai_therapist_app/core/styling/theme_text_styles.dart';
import 'package:ai_therapist_app/features/home/data/models/weekly_letter_model.dart';
import 'package:ai_therapist_app/features/home/presentation/cubit/weekly_letter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

/// Floating dismissible weekly-letter card shown at the top of the home screen.
/// The user swipes it away (or taps ×) to hide it for this session.
class WeeklyLetterBanner extends StatefulWidget {
  const WeeklyLetterBanner({super.key});

  @override
  State<WeeklyLetterBanner> createState() => _WeeklyLetterBannerState();
}

class _WeeklyLetterBannerState extends State<WeeklyLetterBanner>
    with SingleTickerProviderStateMixin {
  bool _dismissed = false;
  late final AnimationController _dismissController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _dismissController.reverse().then((_) {
      if (mounted) setState(() => _dismissed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return BlocBuilder<WeeklyLetterCubit, WeeklyLetterState>(
      builder: (context, state) {
        if (state is WeeklyLetterLoading) {
          return _shell(
            context,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/plant_sprout.json',
                  width: 24,
                  height: 24,
                  repeat: true,
                ),
              ),
            ),
          );
        }

        if (state is! WeeklyLetterLoaded) return const SizedBox.shrink();

        return _shell(
          context,
          child: _LetterContent(data: state.data, onDismiss: _dismiss),
        );
      },
    );
  }

  Widget _shell(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Dismissible(
        key: const ValueKey('weekly_letter_banner'),
        onDismissed: (_) => setState(() => _dismissed = true),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.bannerGradientDarkStart, AppColors.darkSurface]
                  : [AppColors.lightSurface, AppColors.bannerGradientLightEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LetterContent extends StatefulWidget {
  const _LetterContent({required this.data, required this.onDismiss});

  final WeeklyLetterModel data;
  final VoidCallback onDismiss;

  @override
  State<_LetterContent> createState() => _LetterContentState();
}

class _LetterContentState extends State<_LetterContent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final stats = widget.data.stats;
    final hasLetter =
        widget.data.letter != null && widget.data.letter!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: title + dismiss ──────────────────────────
          Row(
            children: [
              const Text(
                '✉️',
                style: TextStyle(
                  fontSize: 18,
                  fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your weekly letter',
                  style: ThemeTextStyles.labelMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onDismiss,
                icon: const Icon(Icons.close_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: context.extra.secondaryTextColor,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Stats row ─────────────────────────────────────────
          Row(
            children: [
              _StatChip(
                label: '${stats.entryCount} entries',
                icon: Icons.edit_note_rounded,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: '🔥 ${stats.streak} day streak',
                isEmoji: true,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: stats.dominantEmoji,
                isEmoji: true,
              ),
            ],
          ),

          // ── Letter body (expandable) ───────────────────────────
          if (hasLetter) ...[
            const SizedBox(height: 10),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                widget.data.letter!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ThemeTextStyles.bodySmall(context),
              ),
              secondChild: Text(
                widget.data.letter!,
                style: ThemeTextStyles.bodySmall(context),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Show less' : 'Read more',
                style: ThemeTextStyles.labelSmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Keep journaling — your letter will be ready at the end of the week.',
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: context.extra.secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    this.icon,
    this.isEmoji = false,
  });

  final String label;
  final IconData? icon;
  final bool isEmoji;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: isEmoji
                ? const TextStyle(
                    fontSize: 13,
                    fontFamilyFallback: [
                      'Apple Color Emoji',
                      'Noto Color Emoji',
                    ],
                  )
                : ThemeTextStyles.labelSmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}
