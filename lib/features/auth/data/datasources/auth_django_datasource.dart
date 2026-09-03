import 'package:dio/dio.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/features/auth/data/models/django_user_model.dart';

typedef VerifyTokenResult = ({DjangoUserModel user, bool isNewUser});

class AuthDjangoDatasource {
  final Dio _dio;

  const AuthDjangoDatasource(this._dio);

  /// Sends the Firebase ID token to the Django backend for verification;
  /// Django creates the user if new and returns `is_new_user` so callers react only once.
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

  /// PATCHes the signed-in user's preferred language to the backend. Callers
  /// treat failures as non-fatal, retried on the next language change or app open.
  Future<void> updatePreferredLanguage(String languageCode) async {
    await _dio.patch(
      ApiEndpoints.accountsMe,
      data: {'preferred_language': languageCode},
    );
  }

  /// Permanently, hard-deletes the signed-in user's account on the backend
  /// (Firebase user included). Must be called while the Firebase session is
  /// still active so the auth interceptor can attach a valid token.
  Future<void> deleteAccount() async {
    await _dio.delete(ApiEndpoints.deleteAccount);
  }
}
