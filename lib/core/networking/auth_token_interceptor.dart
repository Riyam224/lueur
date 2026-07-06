import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Attaches a fresh Firebase ID token as a Bearer token to every outgoing
/// request. Token refresh is handled automatically by the Firebase SDK.
/// Skips silently when no user is signed in (e.g. the verify call itself).
class AuthTokenInterceptor extends Interceptor {
  final FirebaseAuth _firebaseAuth;

  const AuthTokenInterceptor(this._firebaseAuth);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
