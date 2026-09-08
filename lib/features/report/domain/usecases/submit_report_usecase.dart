import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/report/domain/repositories/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository _repository;

  SubmitReportUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String reportedText,
    String? userMessage,
    required String reason,
    String? comment,
  }) {
    return _repository.submitReport(
      reportedText: reportedText,
      userMessage: userMessage,
      reason: reason,
      comment: comment,
    );
  }
}
