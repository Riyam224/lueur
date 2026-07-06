import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;

  const UserEntity({required this.id, required this.email, this.name});

  /// Falls back to the email's local part when no name was provided.
  String get displayName {
    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) return trimmedName;

    final localPart = email.split('@').first.trim();
    return localPart.isNotEmpty ? localPart : email;
  }

  @override
  List<Object?> get props => [id, email, name];
}
