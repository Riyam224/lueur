import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/auth/presentation/widgets/guest_warning_dialog.dart';

/// Shows the guest-mode warning dialog and, if confirmed, enters guest mode.
/// Returns true once [AuthCubit] settles into [AuthGuest] — shared by login/register.
Future<bool> attemptContinueAsGuest(BuildContext context) async {
  final choice = await GuestWarningDialog.show(context);
  if (!context.mounted || choice != GuestWarningChoice.continueAsGuest) {
    return false;
  }

  await context.read<AuthCubit>().enterGuestMode();
  if (!context.mounted) return false;
  return context.read<AuthCubit>().state is AuthGuest;
}
