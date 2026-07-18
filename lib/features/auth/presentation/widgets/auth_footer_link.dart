import 'package:flutter/material.dart';
import 'package:lueur_app/core/styling/app_text_styles.dart';

/// "`prompt` `action`" tappable line shown under the social sign-in button
/// (e.g. "Don't have an account? Start growing").
class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final Color promptColor;
  final Color actionColor;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.promptColor,
    required this.actionColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: prompt,
                style: AppTextStyles.caption(context)
                    .copyWith(color: promptColor),
              ),
              TextSpan(
                text: action,
                style: AppTextStyles.captionEmphasis(context)
                    .copyWith(color: actionColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
