import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:lueur/features/auth/presentation/cubit/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  ForgotPasswordCubit(this._forgotPasswordUseCase)
      : super(const ForgotPasswordInitial());

  Future<void> sendResetEmail(String email) async {
    emit(const ForgotPasswordLoading());
    final result = await _forgotPasswordUseCase(email: email);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }
}
