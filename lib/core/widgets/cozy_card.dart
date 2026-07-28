import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/sketchy_border_painter.dart';

/// The app's standard "cute" card: an asymmetric (hand-drawn-feeling) rounded
/// rect, a soft ambient shadow, and an optional sketchy outline — built with
/// [CustomPainter]/[BoxDecoration] only, no illustration assets required.
class CozyCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool sketchyOutline;
  final Color? outlineColor;

  const CozyCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.sketchyOutline = false,
    this.outlineColor,
  });

  static final BorderRadius _asymmetricRadius = BorderRadius.only(
    topLeft: Radius.circular(22.r),
    topRight: Radius.circular(26.r),
    bottomLeft: Radius.circular(26.r),
    bottomRight: Radius.circular(20.r),
  );

  @override
  Widget build(BuildContext context) {
    final fill = color ?? context.extra.cardBackgroundColor!;
    final shadow = context.extra.shadowColor ?? AppColors.shadowColor;

    return Container(
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: _asymmetricRadius,
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: sketchyOutline
          ? CustomPaint(
              foregroundPainter: SketchyBorderPainter(
                color: outlineColor ?? context.extra.borderColor!,
                radius: 22.r,
              ),
              child: child,
            )
          : child,
    );
  }
}
