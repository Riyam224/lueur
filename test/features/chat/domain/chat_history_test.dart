import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/utils/chat_history.dart';

ChatMessage _user(String c) =>
    ChatMessage(role: ChatMessage.roleUser, content: c);
ChatMessage _luna(String c) =>
    ChatMessage(role: ChatMessage.roleAssistant, content: c);

void main() {
  test('a send-failed bubble never reaches the history', () {
    final history = buildChatHistory([
      _user('hi'),
      _luna('${ChatMessage.sendFailedSentinelPrefix}3'),
      _user('hello again'),
    ]);

    expect(history.map((m) => m.content), ['hi', 'hello again']);
  });

  test('two user turns in a row are kept as they are', () {
    final history = buildChatHistory([_user('a'), _user('b')]);

    expect(history.map((m) => m.role), ['user', 'user']);
  });

  test('empty messages are dropped', () {
    final history = buildChatHistory([_user('a'), _luna('  '), _user('')]);

    expect(history.map((m) => m.content), ['a']);
  });

  test('only the last 10 turns are kept', () {
    final messages = List.generate(15, (i) => _user('m$i'));

    final history = buildChatHistory(messages);

    expect(history.length, 10);
    expect(history.first.content, 'm5');
    expect(history.last.content, 'm14');
  });

  test('turns are counted after dropping failure bubbles', () {
    final messages = [
      for (var i = 0; i < 10; i++) _user('m$i'),
      _luna('${ChatMessage.sendFailedSentinelPrefix}0'),
    ];

    final history = buildChatHistory(messages);

    expect(history.length, 10);
    expect(history.first.content, 'm0');
  });

  test('a single item over 5000 characters is cut to 5000', () {
    final history = buildChatHistory([_luna('x' * 6000)]);

    expect(history.single.content.length, 5000);
  });

  test('the total is capped at 12000 characters, dropping the oldest turns',
      () {
    final history = buildChatHistory([
      _user('a' * 5000),
      _luna('b' * 5000),
      _user('c' * 5000),
    ]);

    expect(history.map((m) => m.content[0]), ['b', 'c']);
    expect(
      history.fold<int>(0, (sum, m) => sum + m.content.length),
      lessThanOrEqualTo(12000),
    );
  });

  test('only the roles user and assistant are sent', () {
    final history = buildChatHistory([
      const ChatMessage(role: 'system', content: 'x'),
      _user('a'),
    ]);

    expect(history.map((m) => m.role), ['user']);
  });
}
