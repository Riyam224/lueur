// lib/features/chat/domain/repositories/chat_repository.dart

import 'package:ai_therapist_app/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<String> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  });
}
