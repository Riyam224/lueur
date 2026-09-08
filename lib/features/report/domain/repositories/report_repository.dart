import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';

abstract class ReportRepository {
  Future<Either<Failure, void>> submitReport({
    required String reportedText,
    String? userMessage,
    required String reason,
    String? comment,
  });
}
