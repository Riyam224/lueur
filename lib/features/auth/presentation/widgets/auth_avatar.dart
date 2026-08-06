import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_extra_colors.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';

/// Luna avatar shown at the top of the login/register screens, sat on a
/// soft circle backdrop (matching the onboarding "circle behind Luna"
/// motif).
class AuthAvatar extends StatelessWidget {
  const AuthAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final circleSize = AuthConstants.avatarSize * 1.35;

    final circleColor =
        Theme.of(context).extension<AppExtraColors>()!.authAvatarCircleBg!;

    return Center(
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circleColor,
        ),
        alignment: Alignment.center,
        child: Image.asset(
          AppAssets.lunaCharacter,
          width: AuthConstants.avatarSize,
          height: AuthConstants.avatarSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
