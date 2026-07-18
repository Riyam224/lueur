import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lueur_app/core/constants/app_sizes.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';

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
                  : (extra.cardBackgroundColor ?? Colors.white);

              return Padding(
                padding:
                    EdgeInsets.only(right: index < emojis.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onEmojiSelected(emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: tileWidth,
                    height: tileHeight,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tileBg
                          : tileBg.withValues(alpha: isDark ? 1.0 : 0.65),
                      borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusMd),
                      border: Border.all(
                        color: isSelected
                            ? highlightColor
                            : (extra.borderColor ?? Colors.transparent),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: highlightColor.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: hasIllustrations
                        ? Padding(
                            padding: const EdgeInsets.all(6),
                            child: _buildIllustration(
                              illustrationPaths![index],
                              tileHeight * 0.78,
                            ),
                          )
                        : Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(
                                fontSize: 30,
                                fontFamilyFallback: [
                                  'Apple Color Emoji',
                                  'Noto Color Emoji',
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
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
