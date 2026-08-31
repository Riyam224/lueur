import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';

class SendChatMessageUseCase {
  final ChatRepository repository;
  const SendChatMessageUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) =>
      repository.sendMessage(
        userId: userId,
        emoji: emoji,
        thoughts: thoughts,
        history: history,
      );
}
