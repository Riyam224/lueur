import 'package:dio/dio.dart';
import 'package:lueur/core/networking/api_endpoints.dart';

abstract class ReportRemoteDataSource {
  Future<void> submitReport({
    required String reportedText,
    String? userMessage,
    required String reason,
    String? comment,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final Dio dio;

  ReportRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> submitReport({
    required String reportedText,
    String? userMessage,
    required String reason,
    String? comment,
  }) async {
    await dio.post(
      ApiEndpoints.report,
      data: {
        'reported_text': reportedText,
        'reason': reason,
        if (userMessage != null && userMessage.isNotEmpty)
          'user_message': userMessage,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }
}
