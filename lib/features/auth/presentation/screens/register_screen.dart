import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/app_blob_background.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/utils/auth_validators.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_avatar.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_success_dialog.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:lueur/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:lueur/features/auth/presentation/widgets/guest_warning_dialog.dart';
import 'package:lueur/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:lueur/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  PasswordStrength _passwordStrength = PasswordStrength.none;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = PasswordStrengthX.fromPassword(value);
      if (_passwordError != null) _passwordError = null;
    });
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      unawaited(_showSuccessThenNavigate(context));
    } else if (state is AuthError) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: cs.error,
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

  void _submit(BuildContext context) {
    final nameError = AuthValidators.required(context, _nameController.text);
    final emailError = AuthValidators.email(context, _emailController.text);
    final passwordError =
        AuthValidators.password(context, _passwordController.text);
    final confirmError = AuthValidators.confirmPassword(
      context,
      _passwordController.text,
      _confirmPasswordController.text,
    );
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmError;
    });
    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null) {
      return;
    }

    context.read<AuthCubit>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
  }

  Future<void> _onContinueAsGuest(BuildContext context) async {
    final choice = await GuestWarningDialog.show(context);
    if (!context.mounted || choice != GuestWarningChoice.continueAsGuest) {
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
                          .copyWith(color: secondaryText),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingLg),
                  AuthTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    label: AppLocalizations.of(context)!.authFullNameLabel,
                    hint: AppLocalizations.of(context)!.authFullNameHint,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocus),
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingSm),
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
                    textInputAction: TextInputAction.next,
                    errorText: _passwordError,
                    onChanged: _onPasswordChanged,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocus),
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
                  SizedBox(height: AppSpacing.sectionSpacingSm),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    label:
                        AppLocalizations.of(context)!.authConfirmPasswordLabel,
                    hint: AppLocalizations.of(context)!.authConfirmPasswordHint,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmPasswordError,
                    onChanged: (_) {
                      if (_confirmPasswordError != null) {
                        setState(() => _confirmPasswordError = null);
                      }
                    },
                    onFieldSubmitted: (_) => _submit(context),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: secondaryText,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.verticalPaddingXl),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => AuthPrimaryButton(
                      label: AppLocalizations.of(context)!.registerCta,
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
                    label: AppLocalizations.of(context)!.authSignUpWithGoogle,
                    borderColor: borderColor,
                    foregroundColor: textPrimary,
                    onPressed: () =>
                        context.read<AuthCubit>().signInWithGoogle(),
                  ),
                  SizedBox(height: AuthConstants.googleToFooterSpacing),
                  AuthFooterLink(
                    prompt: AppLocalizations.of(context)!.registerSignInPrompt,
                    action: AppLocalizations.of(context)!.registerSignInAction,
                    promptColor: secondaryText,
                    actionColor: cs.primary,
                    onTap: () => context.go(AppRoutes.loginScreen),
                  ),
                  SizedBox(height: AppSpacing.sectionSpacingSm),
                  // ── Guest entry ──────────────────────────────────────────
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
