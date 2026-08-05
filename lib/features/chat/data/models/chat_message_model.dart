import 'package:lueur/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel {
  final String role;
  final String content;

  const ChatMessageModel({
    required this.role,
    required this.content,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        role: json['role'] as String,
        content: json['content'] as String,
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessageModel.fromEntity(ChatMessage entity) => ChatMessageModel(
        role: entity.role,
        content: entity.content,
      );

  ChatMessage toEntity() => ChatMessage(
        role: role,
        content: content,
      );
}
