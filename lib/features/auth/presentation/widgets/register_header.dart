import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_avatar.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Avatar, title, and subtitle at the top of the register form.
class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key, required this.secondaryText});

  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const AuthAvatar(),
        SizedBox(height: AuthConstants.avatarToTitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            l10n.registerTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineItalic(context),
          ),
        ),
        SizedBox(height: AuthConstants.titleToSubtitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            l10n.registerSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: secondaryText),
          ),
        ),
      ],
    );
  }
}
