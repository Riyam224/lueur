import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/app_blob_background.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/utils/auth_error_snackbar.dart';
import 'package:lueur/features/auth/presentation/utils/auth_guest_flow.dart';
import 'package:lueur/features/auth/presentation/utils/auth_success_handler.dart';
import 'package:lueur/features/auth/presentation/utils/auth_validators.dart';
import 'package:lueur/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:lueur/features/auth/presentation/widgets/register_body.dart';
import 'package:lueur/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// Bundles the register form's controllers/focus nodes so the State class
/// doesn't need eight separate fields plus matching dispose boilerplate.
class _RegisterFormControllers {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _controllers = _RegisterFormControllers();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  PasswordStrength _passwordStrength = PasswordStrength.none;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isAgeConfirmed = false;
  String? _ageError;

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = PasswordStrengthX.fromPassword(value);
      if (_passwordError != null) _passwordError = null;
    });
  }

  void _clearNameError(String _) {
    if (_nameError != null) setState(() => _nameError = null);
  }

  void _clearEmailError(String _) {
    if (_emailError != null) setState(() => _emailError = null);
  }

  void _clearConfirmPasswordError(String _) {
    if (_confirmPasswordError != null) {
      setState(() => _confirmPasswordError = null);
    }
  }

  void _togglePasswordVisibility() =>
      setState(() => _obscurePassword = !_obscurePassword);

  void _toggleConfirmPasswordVisibility() =>
      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);

  void _onAgeConfirmedChanged(bool value) {
    setState(() {
      _isAgeConfirmed = value;
      if (value && _ageError != null) _ageError = null;
    });
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      // Both submit paths on this screen (email/password and Google) already
      // gate on _isAgeConfirmed before ever calling AuthCubit, so age is
      // always pre-confirmed by the time AuthAuthenticated arrives here.
      unawaited(handleAuthSuccess(context, state, preConfirmedAge: true));
    } else if (state is AuthError) {
      showAuthErrorSnackBar(context, state.message);
    }
  }

  void _submit(BuildContext context) {
    final nameError = AuthValidators.required(context, _controllers.name.text);
    final emailError = AuthValidators.email(context, _controllers.email.text);
    final passwordError =
        AuthValidators.password(context, _controllers.password.text);
    final confirmError = AuthValidators.confirmPassword(
      context,
      _controllers.password.text,
      _controllers.confirmPassword.text,
    );
    final ageError = _isAgeConfirmed
        ? null
        : AppLocalizations.of(context)!.ageConfirmationError;
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmError;
      _ageError = ageError;
    });
    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null ||
        ageError != null) {
      return;
    }

    context.read<AuthCubit>().register(
          email: _controllers.email.text.trim(),
          password: _controllers.password.text,
          name: _controllers.name.text.trim(),
        );
  }

  void _signInWithGoogle(BuildContext context) {
    if (!_isAgeConfirmed) {
      setState(() {
        _ageError = AppLocalizations.of(context)!.ageConfirmationError;
      });
      return;
    }
    context.read<AuthCubit>().signInWithGoogle();
  }

  Future<void> _onContinueAsGuest(BuildContext context) async {
    final becameGuest = await attemptContinueAsGuest(context);
    if (becameGuest && context.mounted) context.go(AppRoutes.home);
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
              child: RegisterBody(
                nameController: _controllers.name,
                emailController: _controllers.email,
                passwordController: _controllers.password,
                confirmPasswordController: _controllers.confirmPassword,
                nameFocus: _controllers.nameFocus,
                emailFocus: _controllers.emailFocus,
                passwordFocus: _controllers.passwordFocus,
                confirmPasswordFocus: _controllers.confirmPasswordFocus,
                nameError: _nameError,
                emailError: _emailError,
                passwordError: _passwordError,
                confirmPasswordError: _confirmPasswordError,
                obscurePassword: _obscurePassword,
                obscureConfirmPassword: _obscureConfirmPassword,
                passwordStrength: _passwordStrength,
                textPrimary: textPrimary,
                secondaryText: secondaryText,
                borderColor: borderColor,
                primaryColor: cs.primary,
                isAgeConfirmed: _isAgeConfirmed,
                ageError: _ageError,
                onNameChanged: _clearNameError,
                onEmailChanged: _clearEmailError,
                onPasswordChanged: _onPasswordChanged,
                onConfirmPasswordChanged: _clearConfirmPasswordError,
                onTogglePasswordVisibility: _togglePasswordVisibility,
                onToggleConfirmPasswordVisibility:
                    _toggleConfirmPasswordVisibility,
                onAgeConfirmedChanged: _onAgeConfirmedChanged,
                onSubmit: () => _submit(context),
                onGoogleSignIn: () => _signInWithGoogle(context),
                onGoToLogin: () => context.go(AppRoutes.loginScreen),
                onContinueAsGuest: () => _onContinueAsGuest(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
