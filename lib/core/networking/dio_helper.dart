import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/core/networking/auth_token_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sentry_dio/sentry_dio.dart';

class DioHelper {
  late final Dio dio;

  DioHelper(AuthTokenInterceptor authInterceptor) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    dio.interceptors.addAll([
      authInterceptor,
      // Response bodies carry journal content and AI companion replies —
      // must stay inert in release so they're never written to device logs.
      PrettyDioLogger(enabled: kDebugMode),
    ]);
    // Must come after the interceptors above (sentry_dio requires this to be
    // the last Dio setup step) to record HTTP calls as performance spans.
    dio.addSentry();
  }

  Future<Response<dynamic>> getRequest({
    required String endPoint,
    Map<String, dynamic>? query,
  }) =>
      dio.get(endPoint, queryParameters: query);

  Future<Response<dynamic>> postRequest({
    required String endPoint,
    required Map<String, dynamic> data,
  }) =>
      dio.post(endPoint, data: data);

  Future<Response<dynamic>> putRequest({
    required String endPoint,
    required Map<String, dynamic> data,
  }) =>
      dio.put(endPoint, data: data);
}
