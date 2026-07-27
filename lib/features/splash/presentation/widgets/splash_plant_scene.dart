import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/styling/app_assets.dart';

/// Static "Luna and her plant" illustration shown beneath the splash
/// wordmark — Luna's character art paired with the looping plant Lottie,
/// both sized relative to [potHeight].
class SplashPlantScene extends StatelessWidget {
  const SplashPlantScene({super.key, required this.potHeight});

  final double potHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(
          AppAssets.lunaCharacter,
          height: potHeight * 1.6,
          fit: BoxFit.contain,
        ),
        SizedBox(width: potHeight * 0.15),
        Lottie.asset(
          AppAssets.lottiePlant,
          width: potHeight,
          height: potHeight,
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (_, __, ___) => SizedBox(width: potHeight, height: potHeight),
        ),
      ],
    );
  }
}
