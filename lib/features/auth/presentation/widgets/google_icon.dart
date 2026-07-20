import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_assets.dart';

/// Google "G" logo used on the social sign-in button.
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.googleLogo,
      width: AppSizes.iconSm,
      height: AppSizes.iconSm,
    );
  }
}
