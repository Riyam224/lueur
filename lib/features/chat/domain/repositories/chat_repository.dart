import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, String>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  });
}
