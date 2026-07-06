import 'package:ai_therapist_app/core/styling/app_assets.dart';
import 'package:ai_therapist_app/features/auth/presentation/constants/auth_constants.dart';
import 'package:flutter/material.dart';

/// Luna avatar shown at the top of the login/register screens.
class AuthAvatar extends StatelessWidget {
  const AuthAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppAssets.lunaImage,
        width: AuthConstants.avatarSize,
        height: AuthConstants.avatarSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
