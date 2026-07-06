import 'package:ai_therapist_app/core/constants/app_sizes.dart';
import 'package:ai_therapist_app/core/styling/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
