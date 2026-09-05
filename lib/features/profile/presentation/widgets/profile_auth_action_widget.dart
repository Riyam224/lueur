import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Bottom-of-profile auth action: signed-in users see a logout button;
/// a guest session sees Log in / Register buttons instead, since a guest
/// has nothing to log out of.
class ProfileAuthActionWidget extends StatelessWidget {
  const ProfileAuthActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) => state is AuthGuest
          ? const _ProfileGuestAuthButtons()
          : const _ProfileLogoutButton(),
    );
  }
}

class _ProfileLogoutButton extends StatelessWidget {
  const _ProfileLogoutButton();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.read<AuthCubit>().logout(),
      icon: const Icon(Icons.logout_rounded, color: AppColors.errorColor),
      label: Text(
        AppLocalizations.of(context)!.authLogOut,
        style: ThemeTextStyles.bodyMedium(context).copyWith(
          color: AppColors.errorColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          side: BorderSide(color: AppColors.errorColor.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

class _ProfileGuestAuthButtons extends StatelessWidget {
  const _ProfileGuestAuthButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go(AppRoutes.loginScreen),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.profileGuestLogInLabel,
                  style: ThemeTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.spaceMd),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.registerScreen),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.profileGuestRegisterLabel,
                  style: ThemeTextStyles.bodyMedium(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.verticalPaddingSm),
      ],
    );
  }
}
