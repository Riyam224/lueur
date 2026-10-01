import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';

Map<String, dynamic> _json({bool? fallback, Object? id = 0}) => {
      'id': id,
      'user_id': 'u',
      'emoji': '🌱',
      'thoughts': 'hi',
      'ai_response': 'Luna is resting.',
      'created_at': '2026-10-02T10:00:00Z',
      if (fallback != null) 'fallback': fallback,
    };

void main() {
  test('a fallback response is marked as a fallback', () {
    final model = MoodEntryModel.fromJson(_json(fallback: true));

    expect(model.fallback, isTrue);
    expect(model.toEntity().isFallback, isTrue);
  });

  test('a normal response is not a fallback', () {
    final model = MoodEntryModel.fromJson(_json());

    expect(model.fallback, isFalse);
    expect(model.toEntity().isFallback, isFalse);
  });

  test('a missing id is tolerated', () {
    final json = _json(fallback: true)..remove('id');

    expect(MoodEntryModel.fromJson(json).id, 0);
  });

  test('the fallback flag is never written to the cache', () {
    final json = MoodEntryModel.fromJson(_json(fallback: true)).toJson();

    expect(json.containsKey('fallback'), isFalse);
  });
}
