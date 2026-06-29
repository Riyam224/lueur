import 'package:flutter/material.dart';
import '../../../onboarding/presentation/widgets/onboarding_luna_painter.dart';
import '../constants/auth_constants.dart';

/// Circular Luna avatar shown at the top of the login/register screens.
class AuthAvatar extends StatelessWidget {
  final Color backgroundColor;

  const AuthAvatar({super.key, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AuthConstants.avatarSize,
        height: AuthConstants.avatarSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(AuthConstants.avatarPadding),
          child: const CustomPaint(
            painter: OnboardingLunaPainter(),
          ),
        ),
      ),
    );
  }
}
