import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/utils/local_entry_id.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_visual.dart';

void main() {
  test('a local entry id is always negative', () {
    expect(nextLocalEntryId(), isNegative);
  });

  test('ids generated back to back are all distinct', () {
    final ids = List.generate(1000, (_) => nextLocalEntryId());
    expect(ids.toSet().length, ids.length);
  });

  test('ids strictly decrease within a process', () {
    var previous = nextLocalEntryId();
    for (var i = 0; i < 100; i++) {
      final next = nextLocalEntryId();
      expect(next, lessThan(previous));
      previous = next;
    }
  });

  test('a negative id still gives a stable, bounded note tilt', () {
    final id = nextLocalEntryId();
    expect(noteTiltFor(id), noteTiltFor(id));
    expect(noteTiltFor(id).abs(), lessThanOrEqualTo(0.05));
  });
}
