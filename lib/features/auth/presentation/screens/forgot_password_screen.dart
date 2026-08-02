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
import 'package:lueur/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:lueur/features/auth/presentation/utils/auth_validators.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_avatar.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:lueur/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  String? _emailError;

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
    final emailError = AuthValidators.email(context, _emailController.text);
    setState(() => _emailError = emailError);
    if (emailError != null) return;
    context.read<ForgotPasswordCubit>().sendResetEmail(
          _emailController.text.trim(),
        );
  }

  void _onStateChanged(BuildContext context, ForgotPasswordState state) {
    if (state is ForgotPasswordError) {
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

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final secondaryText = extra.secondaryTextColor!;

    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: _onStateChanged,
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
                          errorText: _emailError,
                          onChanged: () {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          onSubmit: () => _onSubmit(context),
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

class _FormContent extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _FormContent({
    required this.emailController,
    required this.isLoading,
    required this.errorText,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            AppLocalizations.of(context)!.forgotPasswordTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineItalic(context),
          ),
        ),
        SizedBox(height: AuthConstants.titleToSubtitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppLocalizations.of(context)!.forgotPasswordSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: extra.secondaryTextColor),
          ),
        ),
        SizedBox(height: AppSpacing.sectionSpacingLg),
        AuthTextField(
          controller: emailController,
          label: AppLocalizations.of(context)!.authEmailLabel,
          hint: AppLocalizations.of(context)!.authEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: errorText,
          onChanged: (_) => onChanged(),
          onFieldSubmitted: (_) => onSubmit(),
        ),
        SizedBox(height: AppSpacing.verticalPaddingXl),
        AuthPrimaryButton(
          label: AppLocalizations.of(context)!.forgotPasswordCta,
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
    final cs = Theme.of(context).colorScheme;
    final extra = context.extra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: AuthConstants.successIconContainerSize,
            height: AuthConstants.successIconContainerSize,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: cs.primary,
              size: AppSizes.iconLg,
            ),
          ),
        ),
        SizedBox(height: AuthConstants.avatarToTitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppLocalizations.of(context)!.forgotPasswordSuccessTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineItalic(context),
          ),
        ),
        SizedBox(height: AuthConstants.titleToSubtitleSpacing),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppLocalizations.of(context)!.forgotPasswordSuccessSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: extra.secondaryTextColor),
          ),
        ),
        SizedBox(height: AppSpacing.sectionSpacingLg),
        AuthPrimaryButton(
          label: AppLocalizations.of(context)!.forgotPasswordBackToLogin,
          isLoading: false,
          onPressed: () => context.go(AppRoutes.loginScreen),
        ),
      ],
    );
  }
}
