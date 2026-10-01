import 'package:dio/dio.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/features/chat/data/models/chat_message_model.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/entities/chat_reply.dart';

abstract class ChatRemoteDataSource {
  Future<ChatReply> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<ChatReply> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async {
    final response = await dio.post(
      ApiEndpoints.generate,
      data: {
        'user_id': userId,
        'emoji': emoji,
        'thoughts': thoughts,
        'history': history
            .map((e) => ChatMessageModel.fromEntity(e).toJson())
            .toList(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    return ChatReply(
      data['ai_response'] as String,
      isFallback: data['fallback'] == true,
    );
  }
}
