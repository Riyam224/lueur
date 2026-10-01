import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/entities/chat_reply.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late ChatRemoteDataSourceImpl datasource;

  setUp(() {
    dio = _MockDio();
    datasource = ChatRemoteDataSourceImpl(dio: dio);
  });

  void respondWith(Map<String, dynamic> data) {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response<dynamic>(
        data: data,
        requestOptions: RequestOptions(),
      ),
    );
  }

  Future<ChatReply> send({List<ChatMessage> history = const []}) =>
      datasource.sendMessage(
        userId: 'u',
        emoji: '🌱',
        thoughts: 'hi',
        history: history,
      );

  test('a normal reply is not a fallback', () async {
    respondWith({'ai_response': 'Hello'});

    final reply = await send();

    expect(reply.text, 'Hello');
    expect(reply.isFallback, isFalse);
  });

  test('a fallback reply is flagged', () async {
    respondWith({'ai_response': 'Luna is resting.', 'fallback': true});

    final reply = await send();

    expect(reply.text, 'Luna is resting.');
    expect(reply.isFallback, isTrue);
  });

  test('history goes out with only the keys role and content', () async {
    respondWith({'ai_response': 'Hello'});

    await send(
      history: const [
        ChatMessage(role: ChatMessage.roleUser, content: 'a'),
      ],
    );

    final body = verify(
      () => dio.post<dynamic>(any(), data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    expect(body['history'], [
      {'role': 'user', 'content': 'a'},
    ]);
  });
}
