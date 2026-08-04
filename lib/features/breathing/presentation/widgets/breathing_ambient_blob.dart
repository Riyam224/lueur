import 'package:flutter/material.dart';

/// A plain soft-colored circle used behind the breathing ring for ambient
/// depth.
class BreathingAmbientBlob extends StatelessWidget {
  const BreathingAmbientBlob({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
