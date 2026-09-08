import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/preferences/age_confirmation_prefs.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/widgets/age_confirmation_dialog.dart';
import 'package:lueur/features/auth/presentation/widgets/auth_success_dialog.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Shared reaction to [AuthAuthenticated], used by both the login and
/// register screens so the age-confirmation gate can't be bypassed by
/// entering through only one of them (e.g. Google sign-in on the login
/// screen, which has no checkbox of its own).
///
/// For a brand-new account ([AuthState.isNewUser]) that hasn't already
/// confirmed its age, this shows a mandatory modal before any success
/// dialog or navigation:
/// - confirmed -> marks [AgeConfirmationPrefs] and continues normally.
/// - declined -> rolls back via [AuthCubit.deleteAccount] and stops. On a
///   successful rollback this shows its own feedback and returns; on a
///   failed rollback it leaves the resulting [AuthError] state for the
///   caller's existing listener to surface, exactly as any other auth
///   error would be.
///
/// Pass [preConfirmedAge] true when the caller already gated account
/// creation on a checkbox (email/password register) — the account is new
/// but its age was already confirmed before the API call, so no modal is
/// shown; the flag is just persisted to keep the record consistent.
Future<void> handleAuthSuccess(
  BuildContext context,
  AuthAuthenticated state, {
  bool preConfirmedAge = false,
}) async {
  final uid = state.user.id;
  final authCubit = context.read<AuthCubit>();

  if (preConfirmedAge) {
    await AgeConfirmationPrefs.markAgeConfirmed(uid);
  } else if (state.isNewUser) {
    final alreadyConfirmed = await AgeConfirmationPrefs.hasConfirmedAge(uid);
    if (!alreadyConfirmed) {
      if (!context.mounted) return;
      final confirmed = await AgeConfirmationDialog.show(context);
      if (!confirmed) {
        await authCubit.deleteAccount();
        if (!context.mounted) return;
        // A failed rollback (network error, etc.) leaves an AuthError state
        // that the caller's own BlocListener already surfaces — only the
        // success case needs feedback here.
        if (authCubit.state is AuthUnauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.ageConfirmationDeclinedMessage,
              ),
            ),
          );
        }
        return;
      }
      await AgeConfirmationPrefs.markAgeConfirmed(uid);
    }
  }

  if (!context.mounted) return;
  await AuthSuccessDialog.show(context);
  if (!context.mounted) return;
  final seenOnboarding = await OnboardingPrefs.hasSeen(uid);
  if (!context.mounted) return;
  context.go(seenOnboarding ? AppRoutes.home : AppRoutes.onBoarding);
}
