import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/report/data/datasources/report_remote_datasource.dart';
import 'package:lueur/features/report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remote;
  final Logger _logger = Logger();

  ReportRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, void>> submitReport({
    required String reportedText,
    String? userMessage,
    required String reason,
    String? comment,
  }) async {
    try {
      await _remote.submitReport(
        reportedText: reportedText,
        userMessage: userMessage,
        reason: reason,
        comment: comment,
      );
      return const Right(null);
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkOfflineFailure());
      }
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      _logger.e('Failed to submit report: $e');
      return Left(NetworkFailure('Failed to submit report: $e'));
    }
  }
}
