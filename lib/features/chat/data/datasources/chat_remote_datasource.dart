// lib/features/chat/data/datasources/chat_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:lueur_app/features/chat/data/models/chat_message_model.dart';
import 'package:lueur_app/features/chat/domain/entities/chat_message.dart';

abstract class ChatRemoteDataSource {
  Future<String> sendMessage({
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
  Future<String> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async {
    final response = await dio.post(
      '/api/therapist/generate/',
      data: {
        'user_id': userId,
        'emoji': emoji,
        'thoughts': thoughts,
        'history': history
            .map((e) => ChatMessageModel.fromEntity(e).toJson())
            .toList(),
      },
    );

    return response.data['ai_response'] as String;
  }
}
