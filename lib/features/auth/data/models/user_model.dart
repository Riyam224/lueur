import 'package:ai_therapist_app/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email, super.name});

  factory UserModel.fromFirebaseUser(fb.User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
  }
}
