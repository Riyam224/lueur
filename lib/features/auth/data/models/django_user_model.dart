import 'package:lueur_app/features/auth/domain/entities/user_entity.dart';

class DjangoUserModel extends UserEntity {
  const DjangoUserModel({
    required super.id,
    required super.email,
    super.name,
  });

  factory DjangoUserModel.fromJson(Map<String, dynamic> json) {
    return DjangoUserModel(
      id: json['firebase_uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
    );
  }
}
