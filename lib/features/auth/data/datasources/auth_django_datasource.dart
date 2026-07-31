import 'package:dio/dio.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/features/auth/data/models/django_user_model.dart';

typedef VerifyTokenResult = ({DjangoUserModel user, bool isNewUser});

class AuthDjangoDatasource {
  final Dio _dio;

  const AuthDjangoDatasource(this._dio);

  /// Sends the Firebase ID token to the Django backend for verification.
  /// Django creates the user if they are new, then returns the profile
  /// alongside `is_new_user` so callers can react only once, on creation.
  Future<VerifyTokenResult> verifyToken(String idToken) async {
    final response = await _dio.post(
      ApiEndpoints.authVerify,
      data: {'firebase_token': idToken},
    );
    final data = response.data as Map<String, dynamic>;
    return (
      user: DjangoUserModel.fromJson(data),
      isNewUser: data['is_new_user'] as bool? ?? false,
    );
  }

  /// PATCHes the signed-in user's preferred language to the backend.
  /// Callers treat failures as non-fatal — offline/transient errors are
  /// expected to be retried on the next language change or app open.
  Future<void> updatePreferredLanguage(String languageCode) async {
    await _dio.patch(
      ApiEndpoints.accountsMe,
      data: {'preferred_language': languageCode},
    );
  }
}
