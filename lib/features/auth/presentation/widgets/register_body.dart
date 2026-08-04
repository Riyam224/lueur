import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_guest_entry_button.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_logout_button.dart';
import 'package:lueur/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:lueur/features/auth/presentation/widgets/register_actions_section.dart';
import 'package:lueur/features/auth/presentation/widgets/register_form_fields.dart';
import 'package:lueur/features/auth/presentation/widgets/register_header.dart';

/// Composes the register screen's scrollable content: logout button,
/// header, form fields, primary/Google actions, and guest entry — kept
/// separate from [RegisterScreen]'s State so that state class only holds
/// lifecycle and validation/submit logic.
class RegisterBody extends StatelessWidget {
  const RegisterBody({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmPasswordFocus,
    required this.nameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.passwordStrength,
    required this.textPrimary,
    required this.secondaryText,
    required this.borderColor,
    required this.primaryColor,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.onGoToLogin,
    required this.onContinueAsGuest,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmPasswordFocus;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final PasswordStrength passwordStrength;
  final Color textPrimary;
  final Color secondaryText;
  final Color borderColor;
  final Color primaryColor;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGoToLogin;
  final VoidCallback onContinueAsGuest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthLogoutButton(secondaryText: secondaryText),
        SizedBox(height: AuthConstants.topSpacing),
        RegisterHeader(secondaryText: secondaryText),
        SizedBox(height: AppSpacing.sectionSpacingLg),
        RegisterFormFields(
          nameController: nameController,
          emailController: emailController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
          nameFocus: nameFocus,
          emailFocus: emailFocus,
          passwordFocus: passwordFocus,
          confirmPasswordFocus: confirmPasswordFocus,
          nameError: nameError,
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
          obscurePassword: obscurePassword,
          obscureConfirmPassword: obscureConfirmPassword,
          passwordStrength: passwordStrength,
          borderColor: borderColor,
          secondaryText: secondaryText,
          onNameChanged: onNameChanged,
          onEmailChanged: onEmailChanged,
          onPasswordChanged: onPasswordChanged,
          onConfirmPasswordChanged: onConfirmPasswordChanged,
          onTogglePasswordVisibility: onTogglePasswordVisibility,
          onToggleConfirmPasswordVisibility: onToggleConfirmPasswordVisibility,
          onSubmit: onSubmit,
        ),
        SizedBox(height: AppSpacing.verticalPaddingXl),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => RegisterActionsSection(
            isLoading: state is AuthLoading,
            borderColor: borderColor,
            secondaryText: secondaryText,
            textPrimary: textPrimary,
            primaryColor: primaryColor,
            onSubmit: onSubmit,
            onGoogleSignIn: onGoogleSignIn,
            onGoToLogin: onGoToLogin,
          ),
        ),
        SizedBox(height: AppSpacing.sectionSpacingSm),
        AuthGuestEntryButton(
          secondaryText: secondaryText,
          onPressed: onContinueAsGuest,
        ),
        SizedBox(height: AppSpacing.verticalPaddingXl),
      ],
    );
  }
}
