import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lueur/features/auth/data/models/user_model.dart';

typedef FirebaseAuthResult = ({UserModel user, String idToken});

class AuthFirebaseDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  const AuthFirebaseDataSource({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  User? get currentUser => _firebaseAuth.currentUser;

  /// Forces a refresh of the ID token so a session restored from local
  /// storage is checked against Firebase rather than trusting a cached,
  /// possibly-expired token.
  Future<String> refreshIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No signed-in user');
    final token = await user.getIdToken(true);
    if (token == null) throw StateError('Failed to refresh ID token');
    return token;
  }

  Future<FirebaseAuthResult> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toResult(credential.user!);
  }

  Future<FirebaseAuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();
    return _toResult(_firebaseAuth.currentUser!);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<FirebaseAuthResult> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw const GoogleSignInCancelledException();

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _toResult(userCredential.user!);
  }

  Future<FirebaseAuthResult> _toResult(User user) async {
    final idToken = await user.getIdToken() ?? '';
    return (user: UserModel.fromFirebaseUser(user), idToken: idToken);
  }
}

class GoogleSignInCancelledException implements Exception {
  const GoogleSignInCancelledException();
}
