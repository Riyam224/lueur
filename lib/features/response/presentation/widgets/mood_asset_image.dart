import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a mood illustration from either an SVG or raster asset path,
/// since mood asset paths can point to either.
class MoodAssetImage extends StatelessWidget {
  const MoodAssetImage({super.key, required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return asset.endsWith('.svg')
        ? SvgPicture.asset(asset, width: size, height: size)
        : Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
  }
}
