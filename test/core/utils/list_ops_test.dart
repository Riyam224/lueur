import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/utils/list_ops.dart';

void main() {
  group('withoutFirstWhere', () {
    test('drops only the first match', () {
      expect(withoutFirstWhere([0, 0, 1, 0], (e) => e == 0), [0, 1, 0]);
    });

    test('drops the single match', () {
      expect(withoutFirstWhere([1, 2, 3], (e) => e == 2), [1, 3]);
    });

    test('returns an equal copy when nothing matches', () {
      final original = [1, 2];
      final result = withoutFirstWhere(original, (e) => e == 9);

      expect(result, [1, 2]);
      expect(identical(result, original), isFalse);
    });

    test('never mutates the input', () {
      final original = [1, 2, 3];
      withoutFirstWhere(original, (e) => e == 2);

      expect(original, [1, 2, 3]);
    });
  });
}
