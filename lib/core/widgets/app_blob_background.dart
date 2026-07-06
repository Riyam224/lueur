import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:flutter/material.dart';

/// Decorative blob background matching the splash / onboarding visual palette.
/// Wrap any screen body with this widget to apply the soft blob decoration.
class AppBlobBackground extends StatelessWidget {
  const AppBlobBackground({super.key, required this.child});

  final Widget child;

  static const double _edgeOffsetFactor = 0.35;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        _Blob.aligned(
          size: size.width * 0.55,
          alignment: Alignment.topLeft,
          color: AppColors.lavender,
          opacity: 0.40,
        ),
        _Blob.aligned(
          size: size.width * 0.22,
          alignment: Alignment.topRight,
          color: AppColors.lavender,
          opacity: 0.22,
        ),
        _Blob.aligned(
          size: size.width * 0.30,
          alignment: Alignment.bottomLeft,
          color: AppColors.primaryContainer,
          opacity: 0.28,
        ),
        _Blob.aligned(
          size: size.width * 0.50,
          alignment: Alignment.bottomRight,
          color: AppColors.softLavender,
          opacity: 0.55,
        ),
        _Blob.positioned(
          size: size.width * 0.18,
          dx: size.width * 0.60,
          dy: size.height * 0.08,
          color: AppColors.lavender,
          opacity: 0.18,
        ),
        _Blob.positioned(
          size: size.width * 0.14,
          dx: size.width * 0.10,
          dy: size.height * 0.55,
          color: AppColors.primaryContainer,
          opacity: 0.20,
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob.aligned({
    required this.size,
    required this.alignment,
    required this.color,
    required this.opacity,
  })  : dx = null,
        dy = null;

  const _Blob.positioned({
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
      final offset = size * AppBlobBackground._edgeOffsetFactor;
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
