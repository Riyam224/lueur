import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Attaches a fresh Firebase ID token as a Bearer token to every outgoing
/// request; skips silently when no user is signed in.
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
      try {
        final token = await user.getIdToken(true); // force refresh

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        // Token refresh failed — let the request continue without auth rather
        // than killing it silently; the backend will correctly return 401.
      }
    }
    handler.next(options);
  }
}
