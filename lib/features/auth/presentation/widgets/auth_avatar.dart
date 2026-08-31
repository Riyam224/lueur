import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_extra_colors.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';

/// Luna avatar at the top of login/register, on a soft circle backdrop
/// (matching onboarding's "circle behind Luna") with a gentle floating loop.
class AuthAvatar extends StatefulWidget {
  const AuthAvatar({super.key});

  @override
  State<AuthAvatar> createState() => _AuthAvatarState();
}

class _AuthAvatarState extends State<AuthAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

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
        child: AnimatedBuilder(
          animation: _float,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _float.value),
            child: child,
          ),
          child: Image.asset(
            AppAssets.lunaCharacter,
            width: AuthConstants.avatarSize,
            height: AuthConstants.avatarSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
