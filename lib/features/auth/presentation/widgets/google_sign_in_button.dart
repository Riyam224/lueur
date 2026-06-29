import 'package:flutter/material.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../constants/auth_constants.dart';
import 'google_icon.dart';

/// Outlined "Continue/Sign up with Google" button.
class GoogleSignInButton extends StatelessWidget {
  final String label;
  final Color borderColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.label,
    required this.borderColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AuthConstants.googleButtonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor,
            width: AuthConstants.fieldBorderWidth,
          ),
          shape: const StadiumBorder(),
          foregroundColor: foregroundColor,
        ),
        icon: const GoogleIcon(),
        label: Text(label, style: AppTextStyles.buttonOutlined(context)),
      ),
    );
  }
}
