import 'package:flutter/material.dart';
import 'package:lueur/features/splash/presentation/constants/splash_constants.dart';

/// A soft, translucent circle used to decorate the splash screen background.
class SplashBlob extends StatelessWidget {
  const SplashBlob.aligned({
    super.key,
    required this.size,
    required this.alignment,
    required this.color,
    required this.opacity,
  })  : dx = null,
        dy = null;

  const SplashBlob.positioned({
    super.key,
    required this.size,
    required this.dx,
    required this.dy,
    required this.color,
    required this.opacity,
  }) : alignment = null;

  final double size;
  final Alignment? alignment;
  final double? dx;
  final double? dy;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );

    if (alignment != null) {
      final isLeft =
          alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
      final isTop =
          alignment == Alignment.topLeft || alignment == Alignment.topRight;
      final offset = size * SplashConstants.blobEdgeOffsetFactor;

      return Align(
        alignment: alignment!,
        child: Transform.translate(
          offset: Offset(
            isLeft ? -offset : offset,
            isTop ? -offset : offset,
          ),
          child: circle,
        ),
      );
    }

    return Positioned(left: dx, top: dy, child: circle);
  }
}
