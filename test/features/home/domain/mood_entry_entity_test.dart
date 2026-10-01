import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

MoodEntryEntity _entry(
  int id, {
  String emoji = '🌱',
  String thoughts = 'a',
  DateTime? at,
}) =>
    MoodEntryEntity(
      id: id,
      userId: 'uid',
      emoji: emoji,
      thoughts: thoughts,
      aiResponse: '',
      createdAt: at ?? DateTime(2026, 10, 2),
    );

void main() {
  group('MoodEntryEntity.isSameEntryAs', () {
    test('a server id alone identifies the entry', () {
      expect(_entry(7).isSameEntryAs(_entry(7, thoughts: 'other')), isTrue);
    });

    test('different server ids never match', () {
      expect(_entry(7).isSameEntryAs(_entry(8)), isFalse);
    });

    test('id-0 entries match only with the same time, emoji and thoughts', () {
      expect(_entry(0).isSameEntryAs(_entry(0)), isTrue);
      expect(_entry(0).isSameEntryAs(_entry(0, thoughts: 'b')), isFalse);
      expect(_entry(0).isSameEntryAs(_entry(0, emoji: '🌧️')), isFalse);
      expect(
        _entry(0).isSameEntryAs(_entry(0, at: DateTime(2026, 10, 3))),
        isFalse,
      );
    });

    test('negative ids follow the same rule as id 0', () {
      expect(_entry(-1).isSameEntryAs(_entry(-1)), isTrue);
      expect(_entry(-1).isSameEntryAs(_entry(-1, thoughts: 'b')), isFalse);
    });

    test('an id-0 entry never matches a server entry', () {
      expect(_entry(0).isSameEntryAs(_entry(7)), isFalse);
    });
  });
}
