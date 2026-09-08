import 'package:equatable/equatable.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;

  /// True only when this sign-in call itself created the account (fresh
  /// login/register/Google sign-in). False on a restored session
  /// ([AuthCubit.checkSession]), where it wouldn't mean "just signed up."
  final bool isNewUser;

  const AuthAuthenticated(this.user, {this.isNewUser = false});

  @override
  List<Object?> get props => [user, isNewUser];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An explicit, process-local guest session. This state is never persisted,
/// so a cold app start always returns through normal session checking.
final class AuthGuest extends AuthState {
  const AuthGuest();
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
