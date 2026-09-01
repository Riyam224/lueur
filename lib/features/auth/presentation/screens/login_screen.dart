import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/app_blob_background.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/utils/auth_error_snackbar.dart';
import 'package:lueur/features/auth/presentation/utils/auth_validators.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_avatar.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_success_dialog.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:lueur/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:lueur/features/auth/presentation/widgets/guest_warning_dialog.dart';
import 'package:lueur/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      unawaited(_showSuccessThenNavigate(context, state.user.id));
    } else if (state is AuthError) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizeAuthErrorCode(context, state.message)),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          ),
        ),
      );
    }
  }

  Future<void> _showSuccessThenNavigate(BuildContext context, String uid) async {
    await AuthSuccessDialog.show(context);
    if (!context.mounted) return;
    final seenOnboarding = await OnboardingPrefs.hasSeen(uid);
    if (!context.mounted) return;
    context.go(seenOnboarding ? AppRoutes.home : AppRoutes.onBoarding);
  }

  void _submit(BuildContext context) {
    final emailError = AuthValidators.email(context, _emailController.text);
    final passwordError =
        AuthValidators.required(context, _passwordController.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) return;

    context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _onContinueAsGuest(BuildContext context) async {
    final choice = await GuestWarningDialog.show(context);
    if (!context.mounted || choice == null) return;
    if (choice == GuestWarningChoice.registerInstead) {
      context.go(AppRoutes.registerScreen);
      return;
    }

    await context.read<AuthCubit>().enterGuestMode();
    if (!context.mounted) return;
    if (context.read<AuthCubit>().state is AuthGuest) {
      context.go(AppRoutes.home);
    }
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
                      ),
                    ),
                  ),
                  SizedBox(height: AuthConstants.topSpacing),
                  const AuthAvatar(),
                  SizedBox(height: AuthConstants.avatarToTitleSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      AppLocalizations.of(context)!.loginWelcomeBack,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineItalic(context),
                    ),
                  ),
                  SizedBox(height: AuthConstants.titleToSubtitleSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      AppLocalizations.of(context)!.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(context)
                          .copyWith(color: secondaryText),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingLg),
                  AuthTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: AppLocalizations.of(context)!.authEmailLabel,
                    hint: AppLocalizations.of(context)!.authEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocus),
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingSm),
                  AuthTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: AppLocalizations.of(context)!.authPasswordLabel,
                    hint: AppLocalizations.of(context)!.authPasswordHint,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    onFieldSubmitted: (_) => _submit(context),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.forgotPasswordScreen),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.authForgotPassword,
                        style: AppTextStyles.captionSmall(context)
                            .copyWith(color: cs.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.verticalPaddingXl),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => AuthPrimaryButton(
                      label: AppLocalizations.of(context)!.loginCta,
                      isLoading: state is AuthLoading,
                      onPressed: () => _submit(context),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingSm),
                  AuthOrDivider(
                    lineColor: borderColor,
                    textColor: secondaryText,
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingSm),
                  GoogleSignInButton(
                    label: AppLocalizations.of(context)!.authContinueWithGoogle,
                    borderColor: borderColor,
                    foregroundColor: textPrimary,
                    onPressed: () =>
                        context.read<AuthCubit>().signInWithGoogle(),
                  ),
                  SizedBox(height: AuthConstants.googleToFooterSpacing),
                  AuthFooterLink(
                    prompt: AppLocalizations.of(context)!.loginSignUpPrompt,
                    action: AppLocalizations.of(context)!.loginSignUpAction,
                    promptColor: secondaryText,
                    actionColor: cs.primary,
                    onTap: () => context.go(AppRoutes.registerScreen),
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingSm),
                  Center(
                    child: TextButton(
                      onPressed: () => _onContinueAsGuest(context),
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
