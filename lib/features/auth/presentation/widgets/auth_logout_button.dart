import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Top-right "log out" affordance shown on the login/register screens for
/// users who ended up there while already authenticated (e.g. session
/// expired) and need a way back to a clean slate.
class AuthLogoutButton extends StatelessWidget {
  const AuthLogoutButton({super.key, required this.secondaryText});

  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => context.read<AuthCubit>().logout(),
        icon: Icon(
          Icons.logout_rounded,
          size: AppSizes.iconSm,
          color: secondaryText,
        ),
        label: Text(
          AppLocalizations.of(context)!.authLogOut,
          style: AppTextStyles.captionSmall(context)
              .copyWith(color: secondaryText),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
        ),
      ),
    );
  }
}
