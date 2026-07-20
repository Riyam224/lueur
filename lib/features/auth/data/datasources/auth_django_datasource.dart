import 'package:dio/dio.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/features/auth/data/models/django_user_model.dart';

class AuthDjangoDatasource {
  final Dio _dio;

  const AuthDjangoDatasource(this._dio);

  /// Sends the Firebase ID token to the Django backend for verification.
  /// Django creates the user if they are new, then returns the profile.
  Future<DjangoUserModel> verifyToken(String idToken) async {
    final response = await _dio.post(
      ApiEndpoints.authVerify,
      data: {'firebase_token': idToken},
    );
    return DjangoUserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
