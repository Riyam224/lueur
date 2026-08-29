import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';

void main() {
  group('JournalRefreshSignal', () {
    test('starts at 0 and increments on each bump', () async {
      final signal = JournalRefreshSignal();
      expect(signal.state, 0);

      final expectation = expectLater(signal.stream, emitsInOrder([1, 2, 3]));

      signal.bump();
      signal.bump();
      signal.bump();

      await expectation;
      await signal.close();
    });
  });
}
