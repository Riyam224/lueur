import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/preferences/auth_prefs.dart';
import 'package:lueur/features/auth/domain/usecases/check_session_usecase.dart';
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

  /// Clears guest persistence and cross-feature in-memory state after
  /// Firebase has fully signed out, preventing an authenticated reload race.
  final Future<void> Function() _onSessionCleared;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required CheckSessionUseCase checkSessionUseCase,
    required Future<void> Function() onSessionCleared,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _checkSessionUseCase = checkSessionUseCase,
        _onSessionCleared = onSessionCleared,
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
