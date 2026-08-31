import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/bouncy_tap.dart';

/// Large tappable mood tiles. When [illustrationPaths] is provided each tile
/// shows an SVG/PNG illustration; otherwise falls back to unicode emoji text.
class MoodSelectorWidget extends StatelessWidget {
  final List<String> emojis;
  final String? selectedEmoji;
  final ValueChanged<String> onEmojiSelected;
  final List<Color>? moodColors;
  final String? selectedLabel;

  /// Optional illustration asset paths (one per emoji). SVG and PNG supported.
  final List<String>? illustrationPaths;

  /// Optional per-tile background colors (used in light mode only).
  final List<Color>? moodBgColors;

  const MoodSelectorWidget({
    super.key,
    required this.emojis,
    required this.selectedEmoji,
    required this.onEmojiSelected,
    this.moodColors,
    this.selectedLabel,
    this.illustrationPaths,
    this.moodBgColors,
  });

  Widget _buildIllustration(String path, double size) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasIllustrations = illustrationPaths != null &&
        illustrationPaths!.length >= emojis.length;
    final tileHeight =
        hasIllustrations ? 88.h : AppSizes.emojiButtonSize * 1.4;
    final tileWidth = tileHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(emojis.length, (index) {
              final emoji = emojis[index];
              final isSelected = selectedEmoji == emoji;
              final moodColor =
                  (moodColors != null && index < moodColors!.length)
                      ? moodColors![index]
                      : extra.primaryColor!;
              final highlightColor = isDark ? extra.primaryColor! : moodColor;

              // In light mode use the onboarding blob color as tile bg;
              // in dark mode keep the card background.
              final tileBg = (!isDark &&
                      moodBgColors != null &&
                      index < moodBgColors!.length)
                  ? moodBgColors![index]
                  : (extra.cardBackgroundColor ?? AppColors.lightSurface);

              return Padding(
                padding: EdgeInsets.only(
                  right: index < emojis.length - 1 ? AppSpacing.spaceSm : 0,
                ),
                child: _MoodTile(
                  key: ValueKey(emoji),
                  emoji: emoji,
                  isSelected: isSelected,
                  isDark: isDark,
                  tileBg: tileBg,
                  highlightColor: highlightColor,
                  borderColor: extra.borderColor ?? AppColors.transparent,
                  tileWidth: tileWidth,
                  tileHeight: tileHeight,
                  illustrationPath: hasIllustrations
                      ? illustrationPaths![index]
                      : null,
                  buildIllustration: _buildIllustration,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onEmojiSelected(emoji);
                  },
                ),
              );
            }),
          ),
        ),
        SizedBox(height: AppSpacing.spaceMd),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: selectedLabel != null
              ? Text(
                  selectedLabel!,
                  key: ValueKey(selectedLabel),
                  style: ThemeTextStyles.labelMedium(context),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}

/// A single mood tile. Owns a one-shot scale-bounce animation that replays
/// on every tap, separate from the persistent selected-state styling driven by [isSelected].
class _MoodTile extends StatefulWidget {
  final String emoji;
  final bool isSelected;
  final bool isDark;
  final Color tileBg;
  final Color highlightColor;
  final Color borderColor;
  final double tileWidth;
  final double tileHeight;
  final String? illustrationPath;
  final Widget Function(String path, double size) buildIllustration;
  final VoidCallback onTap;

  const _MoodTile({
    required super.key,
    required this.emoji,
    required this.isSelected,
    required this.isDark,
    required this.tileBg,
    required this.highlightColor,
    required this.borderColor,
    required this.tileWidth,
    required this.tileHeight,
    required this.illustrationPath,
    required this.buildIllustration,
    required this.onTap,
  });

  @override
  State<_MoodTile> createState() => _MoodTileState();
}

class _MoodTileState extends State<_MoodTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: _handleTap,
      pressedScale: 0.9,
      child: AnimatedBuilder(
        animation: _bounceScale,
        builder: (context, child) => Transform.scale(
          scale: _bounceScale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: widget.tileWidth,
          height: widget.tileHeight,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.tileBg
                : widget.tileBg.withValues(alpha: widget.isDark ? 1.0 : 0.65),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            border: Border.all(
              color: widget.isSelected
                  ? widget.highlightColor
                  : widget.borderColor,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.highlightColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: widget.illustrationPath != null
              ? Padding(
                  padding: EdgeInsets.all(6.w),
                  child: widget.buildIllustration(
                    widget.illustrationPath!,
                    widget.tileHeight * 0.78,
                  ),
                )
              : Center(
                  child: Text(
                    widget.emoji,
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontFamilyFallback: const [
                        'Apple Color Emoji',
                        'Noto Color Emoji',
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
