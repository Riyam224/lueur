import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur_app/core/constants/app_sizes.dart';
import 'package:lueur_app/core/constants/app_spacing.dart';
import 'package:lueur_app/core/routing/app_routes.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/core/styling/app_text_styles.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/utils/app_strings.dart';
import 'package:lueur_app/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur_app/features/auth/presentation/widgets/auth_avatar.dart';
import 'package:lueur_app/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:lueur_app/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:lueur_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:lueur_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:lueur_app/features/auth/presentation/widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.go(AppRoutes.home);
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
        body: SafeArea(
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
                      AppStrings.authLogOut,
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
                    AppStrings.loginWelcomeBack,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineItalic(context),
                  ),
                ),
                SizedBox(height: AuthConstants.titleToSubtitleSpacing),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    AppStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(color: AppColors.onboardingSubtitle),
                  ),
                ),
                SizedBox(height: AppSpacing.sectionSpacingLg),
                AuthTextField(
                  controller: _emailController,
                  label: AppStrings.authEmailLabel,
                  hint: AppStrings.authEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.sectionSpacingSm),
                AuthTextField(
                  controller: _passwordController,
                  label: AppStrings.authPasswordLabel,
                  hint: AppStrings.authPasswordHint,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
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
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.authForgotPassword,
                      style: AppTextStyles.captionSmall(context)
                          .copyWith(color: AppColors.onboardingAccent),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.verticalPaddingXl),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => AuthPrimaryButton(
                    label: AppStrings.loginCta,
                    isLoading: state is AuthLoading,
                    onPressed: () => context.read<AuthCubit>().login(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
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
                  label: AppStrings.authContinueWithGoogle,
                  borderColor: borderColor,
                  foregroundColor: textPrimary,
                  onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                ),
                SizedBox(height: AuthConstants.googleToFooterSpacing),
                AuthFooterLink(
                  prompt: AppStrings.loginSignUpPrompt,
                  action: AppStrings.loginSignUpAction,
                  promptColor: secondaryText,
                  actionColor: AppColors.onboardingAccent,
                  onTap: () => context.go(AppRoutes.registerScreen),
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
                      AppStrings.authContinueAsGuest,
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
    );
  }
}
