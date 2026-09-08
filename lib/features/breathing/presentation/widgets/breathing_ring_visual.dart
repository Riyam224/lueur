import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/breathing/presentation/widgets/breathing_ambient_blob.dart';

const int _petalCount = 6;
const double _petalDepth = 0.06;

/// Traces the shared scalloped flower-petal silhouette used by both the
/// progress track/arc and the completion bloom, so they always line up.
Path _petalPath(Offset center, double radius) {
  final path = Path();
  const steps = 240;
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final angle = t * 2 * math.pi;
    final wobble = 1 + _petalDepth * math.cos(angle * _petalCount);
    final r = radius * wobble;
    final point = Offset(
      center.dx + r * math.cos(angle - math.pi / 2),
      center.dy + r * math.sin(angle - math.pi / 2),
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
  return path;
}

/// Concentric "ring" frame around Luna — a scalloped flower-shaped track with
/// an animated progress stroke for the current phase, a soft color "bloom"
/// flash each time a phase completes, a cream padding ring, and a pulsing
/// inner circle scaled by [scale] in sync with the phase.
class BreathingRingVisual extends StatelessWidget {
  const BreathingRingVisual({
    super.key,
    required this.scale,
    required this.ringColor,
    required this.phaseProgress,
  });

  final Animation<double> scale;
  final Color ringColor;

  /// Progress (0.0-1.0) through the current breathing phase.
  final double phaseProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.w,
      height: 300.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10.h,
            left: 0,
            child: BreathingAmbientBlob(
              size: 120.w,
              color:
                  AppColors.breathingGradientLavender.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 0,
            child: BreathingAmbientBlob(
              size: 140.w,
              color: AppColors.breathingGradientPeach.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(
            width: 260.w,
            height: 260.w,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: phaseProgress, end: phaseProgress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, animatedProgress, child) => CustomPaint(
                painter: _FlowerRingPainter(
                  progress: animatedProgress,
                  trackColor: ringColor.withValues(alpha: 0.25),
                  progressColor: ringColor,
                ),
              ),
            ),
          ),
          _RingBloom(color: ringColor),
          const _RingSparkles(),
          Container(
            width: 220.w,
            height: 220.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.breathingGradientCream,
            ),
          ),
          AnimatedBuilder(
            animation: scale,
            builder: (context, child) => Transform.scale(
              scale: scale.value,
              child: child,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 188.w,
              height: 188.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ringColor.withValues(alpha: 0.9),
                    ringColor.withValues(alpha: 0.55),
                  ],
                ),
              ),
              padding: EdgeInsets.all(14.w),
              child: Image.asset(AppAssets.lunaCharacter, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

/// Traces a scalloped flower-petal silhouette and paints the current
/// breathing phase's progress as an arc drawn along that same outline.
class _FlowerRingPainter extends CustomPainter {
  _FlowerRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4.w;
    final petalPath = _petalPath(center, radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.w
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(petalPath, trackPaint);

    if (progress <= 0) return;

    final metrics = petalPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLength =
        metrics.fold<double>(0, (sum, metric) => sum + metric.length);
    final targetLength = totalLength * progress.clamp(0.0, 1.0);

    final progressPath = Path();
    var consumed = 0.0;
    for (final metric in metrics) {
      if (consumed >= targetLength) break;
      final remaining = targetLength - consumed;
      final extractLength = math.min(metric.length, remaining);
      progressPath.addPath(metric.extractPath(0, extractLength), Offset.zero);
      consumed += metric.length;
    }

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.w
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _FlowerRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}

/// A soft solid-color flash across the flower shape, played once each time
/// [color] changes — i.e. whenever a breathing phase reaches the end of its
/// shape and the next one begins.
class _RingBloom extends StatelessWidget {
  const _RingBloom({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260.w,
      height: 260.w,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(color),
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        builder: (context, opacity, child) {
          if (opacity <= 0.01) return const SizedBox.shrink();
          return CustomPaint(
            painter: _FlowerBloomPainter(
              color: color.withValues(alpha: opacity * 0.4),
            ),
          );
        },
      ),
    );
  }
}

class _FlowerBloomPainter extends CustomPainter {
  _FlowerBloomPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4.w;
    canvas.drawPath(_petalPath(center, radius), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FlowerBloomPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Small decorative four-pointed sparkles scattered around the ring.
class _RingSparkles extends StatelessWidget {
  const _RingSparkles();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260.w,
      height: 260.w,
      child: Stack(
        children: [
          Positioned(
            top: 18.h,
            right: 28.w,
            child: _Sparkle(size: 16.w, opacity: 0.55),
          ),
          Positioned(
            bottom: 34.h,
            left: 20.w,
            child: _Sparkle(size: 12.w, opacity: 0.4),
          ),
          Positioned(
            top: 70.h,
            left: 6.w,
            child: _Sparkle(size: 10.w, opacity: 0.35),
          ),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(
        color: AppColors.breathingGradientCream.withValues(alpha: opacity),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    final inner = outer * 0.28;

    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final radius = i.isEven ? outer : inner;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}
