import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur_app/core/errors/failures.dart';
import 'package:lueur_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:lueur_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lueur_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:lueur_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:lueur_app/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  /// Called before the logout use case runs — clears cross-feature state
  /// without coupling auth to any specific feature.
  final VoidCallback _onLogout;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required VoidCallback onLogout,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _onLogout = onLogout,
        super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
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
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final result = await _signInWithGoogleUseCase();
    if (isClosed) return;
    result.fold(
      (failure) => failure is CancellationFailure
          ? emit(const AuthInitial())
          : emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    _onLogout();
    final result = await _logoutUseCase();
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
