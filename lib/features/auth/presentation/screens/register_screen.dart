import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/app_blob_background.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_avatar.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_success_dialog.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:lueur/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:lueur/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:lueur/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  PasswordStrength _passwordStrength = PasswordStrength.none;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = PasswordStrengthX.fromPassword(value);
    });
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      unawaited(_showSuccessThenNavigate(context));
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.onboardingAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          ),
        ),
      );
    }
  }

  Future<void> _showSuccessThenNavigate(BuildContext context) async {
    await AuthSuccessDialog.show(context);
    if (!context.mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extra = context.extra;
    final textPrimary = extra.primaryTextColor!;
    final secondaryText = extra.secondaryTextColor!;
    final borderColor = cs.outline;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        body: AppBlobBackground(
          child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPaddingXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logout button ────────────────────────────────────────
                Align(
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
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.spaceSm,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                SizedBox(height: AuthConstants.topSpacing),
                const AuthAvatar(),
                SizedBox(height: AuthConstants.avatarToTitleSpacing),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context)!.registerTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineItalic(context),
                  ),
                ),
                SizedBox(height: AuthConstants.titleToSubtitleSpacing),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context)!.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(color: AppColors.onboardingSubtitle),
                  ),
                ),
                SizedBox(height: AppSpacing.sectionSpacingLg),
                AuthTextField(
                  controller: _nameController,
                  label: AppLocalizations.of(context)!.authFullNameLabel,
                  hint: AppLocalizations.of(context)!.authFullNameHint,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: AppSpacing.sectionSpacingSm),
                AuthTextField(
                  controller: _emailController,
                  label: AppLocalizations.of(context)!.authEmailLabel,
                  hint: AppLocalizations.of(context)!.authEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.sectionSpacingSm),
                AuthTextField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context)!.authPasswordLabel,
                  hint: AppLocalizations.of(context)!.authPasswordHint,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onChanged: _onPasswordChanged,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: secondaryText,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                SizedBox(height: AppSpacing.verticalPaddingXs),
                PasswordStrengthIndicator(
                  strength: _passwordStrength,
                  backgroundColor: borderColor,
                ),
                SizedBox(height: AppSpacing.verticalPaddingXl),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => AuthPrimaryButton(
                    label: AppLocalizations.of(context)!.registerCta,
                    isLoading: state is AuthLoading,
                    onPressed: () => context.read<AuthCubit>().register(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          name: _nameController.text.trim(),
                        ),
                  ),
                ),
                SizedBox(height: AppSpacing.sectionSpacingSm),
                AuthOrDivider(
                  lineColor: borderColor,
                  textColor: secondaryText,
                ),
                SizedBox(height: AppSpacing.sectionSpacingSm),
                GoogleSignInButton(
                  label: AppLocalizations.of(context)!.authSignUpWithGoogle,
                  borderColor: borderColor,
                  foregroundColor: textPrimary,
                  onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                ),
                SizedBox(height: AuthConstants.googleToFooterSpacing),
                AuthFooterLink(
                  prompt: AppLocalizations.of(context)!.registerSignInPrompt,
                  action: AppLocalizations.of(context)!.registerSignInAction,
                  promptColor: secondaryText,
                  actionColor: AppColors.onboardingAccent,
                  onTap: () => context.go(AppRoutes.loginScreen),
                ),
                SizedBox(height: AppSpacing.sectionSpacingSm),
                // ── Guest entry ──────────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    style: TextButton.styleFrom(
                      foregroundColor: secondaryText,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.spaceSm,
                        horizontal: AppSpacing.spaceMd,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.authContinueAsGuest,
                      style: AppTextStyles.caption(context).copyWith(
                        color: secondaryText,
                        decoration: TextDecoration.underline,
                        decorationColor: secondaryText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.verticalPaddingXl),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
