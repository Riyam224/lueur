import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// A single tappable palette dot — grows, rings, and glows in its own color
/// when selected so the active brush color is unmistakable at a glance.
class DrawColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final Color ringColor;
  final VoidCallback onTap;

  const DrawColorSwatch({
    super.key,
    required this.color,
    required this.isSelected,
    required this.ringColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = isSelected
        ? AppSizes.paletteSwatchSizeSelected
        : AppSizes.paletteSwatchSize;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? ringColor : AppColors.transparent,
            width: AppSizes.paletteSwatchBorderWidth,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: AppSizes.paletteSwatchGlowBlur,
                    spreadRadius: AppSizes.paletteSwatchGlowSpread,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
