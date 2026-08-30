import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// A round, glossy pushpin accent for a sticky-note-style journal card —
/// pinned literally through the card's top edge. Every card gets one; a
/// favorited ([isFavorite]) entry gets a brighter gold pin with a soft glow
/// instead of its usual note-matched color, so the "pinned to top" feature
/// stays visible under the decorative styling.
class JournalPushpin extends StatelessWidget {
  const JournalPushpin({
    super.key,
    required this.size,
    required this.cardColor,
    this.isFavorite = false,
  });

  final double size;
  final Color cardColor;
  final bool isFavorite;

  /// A saturated, slightly darker take on [cardColor] so the pin reads as
  /// its own object rather than blending into the pastel note beneath it.
  Color get _pinColor {
    final hsl = HSLColor.fromColor(cardColor);
    return hsl
        .withSaturation((hsl.saturation + 0.35).clamp(0.0, 1.0))
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = isFavorite ? AppColors.accent : _pinColor;
    final highlight = Color.lerp(baseColor, AppColors.whiteTextColor, 0.6)!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [highlight, baseColor],
        ),
        boxShadow: [
          BoxShadow(
            color: (isFavorite ? AppColors.accent : AppColors.overlayBlack)
                .withValues(alpha: isFavorite ? 0.35 : 0.25),
            blurRadius: isFavorite ? 6 : 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
