import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/report/domain/usecases/submit_report_usecase.dart';
import 'package:lueur/features/report/presentation/cubit/report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final SubmitReportUseCase _submitReport;

  ReportCubit(this._submitReport) : super(const ReportInitial());

  Future<void> submitReport({
    required String reportedText,
    String? userMessage,
    required String reason,
    String? comment,
  }) async {
    if (isClosed) return;
    emit(const ReportSubmitting());
    final result = await _submitReport(
      reportedText: reportedText,
      userMessage: userMessage,
      reason: reason,
      comment: comment,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(ReportFailure(failure.message)),
      (_) => emit(const ReportSuccess()),
    );
  }
}
