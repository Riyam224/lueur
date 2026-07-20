import 'package:dio/dio.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/core/networking/auth_token_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHelper {
  late final Dio dio;

  DioHelper(AuthTokenInterceptor authInterceptor) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        receiveDataWhenStatusError: true,
      ),
    );
    dio.interceptors.addAll([authInterceptor, PrettyDioLogger()]);
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
