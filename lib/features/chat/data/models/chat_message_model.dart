// lib/features/chat/data/models/chat_message_model.dart

import 'package:ai_therapist_app/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel {
  final String role;
  final String content;

  const ChatMessageModel({
    required this.role,
    required this.content,
  });

  // From JSON (API response)
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        role: json['role'] as String,
        content: json['content'] as String,
      );

  // To JSON (send to API)
  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  // From Entity → Model
  factory ChatMessageModel.fromEntity(ChatMessage entity) => ChatMessageModel(
        role: entity.role,
        content: entity.content,
      );

  // To Entity
  ChatMessage toEntity() => ChatMessage(
        role: role,
        content: content,
      );
}
