// lib/features/breathing/presentation/widgets/breathing_circle.dart

import 'package:flutter/material.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';

class BreathingCircle extends StatelessWidget {
  final double scale;
  final Color color;
  final String phaseText;

  const BreathingCircle({
    super.key,
    required this.scale,
    required this.color,
    required this.phaseText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.extra.borderColor,
            ),
          ),
          // Inner animated circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 140 * scale,
            height: 140 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Center(
              child: Text(
                phaseText,
                style: ThemeTextStyles.whiteHeadline(context).copyWith(
                  color: context.extra.onPrimaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
