import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Permanent account deletion, kept as its own section — distinct from
/// [ProfileJournalDataSectionWidget]'s "delete all journal entries", which
/// only clears mood data and leaves the account itself intact.
class ProfileAccountSectionWidget extends StatelessWidget {
  const ProfileAccountSectionWidget({super.key});

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.accountDeleteTitle),
            content: Text(l10n.accountDeleteMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  l10n.accountDeleteConfirm,
                  style: const TextStyle(color: AppColors.errorColor),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    await authCubit.deleteAccount();

    // AuthError is a fresh instance per fold — checking right after the
    // await reliably reflects this action's own outcome, not some other
    // screen's unrelated failure on the same shared singleton cubit.
    if (authCubit.state is AuthError) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.accountDeleteFailedSnack)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileAccountSectionLabel,
          style: ThemeTextStyles.labelSmall(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.verticalPaddingSm),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.delete_forever_rounded,
            color: AppColors.errorColor,
          ),
          title: Text(
            l10n.profileDeleteAccountLabel,
            style: const TextStyle(color: AppColors.errorColor),
          ),
          onTap: () => _confirmDeleteAccount(context),
        ),
      ],
    );
  }
}
