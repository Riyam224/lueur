import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:lueur/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Name / email / password / confirm-password fields for the register
/// form, including the password strength indicator and visibility toggles.
class RegisterFormFields extends StatelessWidget {
  const RegisterFormFields({
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
    required this.borderColor,
    required this.secondaryText,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onSubmit,
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
  final Color borderColor;
  final Color secondaryText;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        AuthTextField(
          controller: nameController,
          focusNode: nameFocus,
          label: l10n.authFullNameLabel,
          hint: l10n.authFullNameHint,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          errorText: nameError,
          onChanged: onNameChanged,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(emailFocus),
        ),
        SizedBox(height: AppSpacing.sectionSpacingSm),
        AuthTextField(
          controller: emailController,
          focusNode: emailFocus,
          label: l10n.authEmailLabel,
          hint: l10n.authEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: emailError,
          onChanged: onEmailChanged,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(passwordFocus),
        ),
        SizedBox(height: AppSpacing.sectionSpacingSm),
        AuthTextField(
          controller: passwordController,
          focusNode: passwordFocus,
          label: l10n.authPasswordLabel,
          hint: l10n.authPasswordHint,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          errorText: passwordError,
          onChanged: onPasswordChanged,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(confirmPasswordFocus),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: secondaryText,
            ),
            onPressed: onTogglePasswordVisibility,
          ),
        ),
        SizedBox(height: AppSpacing.verticalPaddingXs),
        PasswordStrengthIndicator(
          strength: passwordStrength,
          backgroundColor: borderColor,
        ),
        SizedBox(height: AppSpacing.sectionSpacingSm),
        AuthTextField(
          controller: confirmPasswordController,
          focusNode: confirmPasswordFocus,
          label: l10n.authConfirmPasswordLabel,
          hint: l10n.authConfirmPasswordHint,
          obscureText: obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          errorText: confirmPasswordError,
          onChanged: onConfirmPasswordChanged,
          onFieldSubmitted: (_) => onSubmit(),
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: secondaryText,
            ),
            onPressed: onToggleConfirmPasswordVisibility,
          ),
        ),
      ],
    );
  }
}
