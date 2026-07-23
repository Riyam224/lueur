import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/auth/presentation/constants/auth_constants.dart';
import 'package:lueur/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_avatar.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.forgotPasswordEmailRequired),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    context.read<ForgotPasswordCubit>().sendResetEmail(email);
  }

  void _onStateChanged(BuildContext context, ForgotPasswordState state) {
    if (state is ForgotPasswordError) {
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
    final extra = context.extra;
    final secondaryText = extra.secondaryTextColor!;

    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: _onStateChanged,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPaddingXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: secondaryText,
                    ),
                  ),
                ),
                SizedBox(height: AuthConstants.avatarToTitleSpacing),
                const AuthAvatar(),
                SizedBox(height: AuthConstants.avatarToTitleSpacing),
                BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  builder: (context, state) => state is ForgotPasswordSuccess
                      ? const _SuccessContent()
                      : _FormContent(
                          emailController: _emailController,
                          isLoading: state is ForgotPasswordLoading,
                          onSubmit: () => _onSubmit(context),
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

class _FormContent extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormContent({
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            AppStrings.forgotPasswordTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineItalic(context),
          ),
        ),
        SizedBox(height: AuthConstants.titleToSubtitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppStrings.forgotPasswordSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: AppColors.onboardingSubtitle),
          ),
        ),
        SizedBox(height: AppSpacing.sectionSpacingLg),
        AuthTextField(
          controller: emailController,
          label: AppStrings.authEmailLabel,
          hint: AppStrings.authEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: AppSpacing.verticalPaddingXl),
        AuthPrimaryButton(
          label: AppStrings.forgotPasswordCta,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: AuthConstants.avatarSize * 0.55,
            height: AuthConstants.avatarSize * 0.55,
            decoration: BoxDecoration(
              color: AppColors.onboardingAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.onboardingAccent,
              size: AppSizes.iconLg,
            ),
          ),
        ),
        SizedBox(height: AuthConstants.avatarToTitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppStrings.forgotPasswordSuccessTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineItalic(context),
          ),
        ),
        SizedBox(height: AuthConstants.titleToSubtitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppStrings.forgotPasswordSuccessSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: AppColors.onboardingSubtitle),
          ),
        ),
        SizedBox(height: AppSpacing.sectionSpacingLg),
        AuthPrimaryButton(
          label: AppStrings.forgotPasswordBackToLogin,
          isLoading: false,
          onPressed: () => context.go(AppRoutes.loginScreen),
        ),
      ],
    );
  }
}
