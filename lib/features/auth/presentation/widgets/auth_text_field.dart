import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';

/// Labeled text field with the shared auth-screen styling (rounded border,
/// filled background, themed focus/error states).
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extra = context.extra;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: AppTextStyles.fieldInput(context)
          .copyWith(color: extra.primaryTextColor),
      decoration: InputDecoration(
        label: Text(
          label,
          style: AppTextStyles.fieldLabel(context)
              .copyWith(color: AppColors.onboardingAccent),
        ),
        hintText: hint,
        hintStyle: AppTextStyles.fieldHint(context)
            .copyWith(color: extra.secondaryTextColor),
        filled: true,
        fillColor: cs.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPaddingMd,
          vertical: AppSpacing.verticalPaddingMd,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthConstants.fieldBorderRadius),
          borderSide: BorderSide(
            color: cs.outline,
            width: AuthConstants.fieldBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthConstants.fieldBorderRadius),
          borderSide: BorderSide(
            color: AppColors.onboardingAccent,
            width: AuthConstants.fieldBorderWidthFocused,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthConstants.fieldBorderRadius),
          borderSide: BorderSide(
            color: cs.error,
            width: AuthConstants.fieldBorderWidthFocused,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthConstants.fieldBorderRadius),
          borderSide: BorderSide(
            color: cs.error,
            width: AuthConstants.fieldBorderWidthFocused,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
