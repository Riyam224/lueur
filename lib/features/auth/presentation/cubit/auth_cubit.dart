import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/preferences/auth_prefs.dart';
import 'package:lueur/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/login_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/register_usecase.dart';
import 'package:lueur/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final CheckSessionUseCase _checkSessionUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  /// Clears guest persistence and cross-feature in-memory state after
  /// Firebase has fully signed out, preventing an authenticated reload race.
  final Future<void> Function() _onSessionCleared;

  /// Wider, permanent local-data wipe for the deleted user's own cached
  /// content (journal, quotes, sudoku, drawings) — deliberately separate
  /// from [_onSessionCleared], whose narrower guest-only scope logout still needs.
  final Future<void> Function(String userId) _onAccountDeleted;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required CheckSessionUseCase checkSessionUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required Future<void> Function() onSessionCleared,
    required Future<void> Function(String userId) onAccountDeleted,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _checkSessionUseCase = checkSessionUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _onSessionCleared = onSessionCleared,
        _onAccountDeleted = onAccountDeleted,
        super(const AuthInitial());

  /// Restores a persisted session on app start. Forces a Firebase ID token
  /// refresh so an expired-but-cached session doesn't silently break Home's first API call.
  Future<void> checkSession() async {
    emit(const AuthLoading());
    final result = await _checkSessionUseCase();
    if (isClosed) return;
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
    if (result.isRight()) await AuthPrefs.markAuthenticated();
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      email: email,
      password: password,
      name: name,
    );
    if (result.isRight()) await AuthPrefs.markAuthenticated();
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final result = await _signInWithGoogleUseCase();
    if (result.isRight()) await AuthPrefs.markAuthenticated();
    if (isClosed) return;
    result.fold(
      (failure) => failure is CancellationFailure
          ? emit(const AuthInitial())
          : emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    final result = await _logoutUseCase();
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        await _onSessionCleared();
        if (!isClosed) emit(const AuthUnauthenticated());
      },
    );
  }

  /// Permanently deletes the signed-in user's account. On success, wipes
  /// that user's own local caches (a wider scope than a plain logout) and
  /// lands on [AuthUnauthenticated] exactly as logout does. On failure,
  /// session state is left untouched — the account still exists.
  Future<void> deleteAccount() async {
    final currentState = state;
    final userId =
        currentState is AuthAuthenticated ? currentState.user.id : null;

    final result = await _deleteAccountUseCase();
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        if (userId != null) await _onAccountDeleted(userId);
        if (!isClosed) emit(const AuthUnauthenticated());
      },
    );
  }

  /// Starts a fresh guest session only after any Firebase/Google session is
  /// completely signed out and anonymous local state has been cleared.
  Future<void> enterGuestMode() async {
    final result = await _logoutUseCase();
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        await _onSessionCleared();
        if (!isClosed) emit(const AuthGuest());
      },
    );
  }
}
