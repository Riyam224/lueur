import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/utils/calendar_days.dart';

void main() {
  group('calendarDaysAgo', () {
    test('earlier the same day is 0', () {
      expect(
        calendarDaysAgo(DateTime(2026, 10, 2, 0, 5), DateTime(2026, 10, 2, 23)),
        0,
      );
    });

    test('late yesterday seen early today is 1, not 0', () {
      expect(
        calendarDaysAgo(DateTime(2026, 10, 1, 23), DateTime(2026, 10, 2, 8)),
        1,
      );
    });

    test('just after midnight counts the previous day as yesterday', () {
      expect(
        calendarDaysAgo(
          DateTime(2026, 10, 1, 23, 59),
          DateTime(2026, 10, 2, 0, 1),
        ),
        1,
      );
    });

    test('counts across a month boundary', () {
      expect(calendarDaysAgo(DateTime(2026, 9, 29), DateTime(2026, 10, 2)), 3);
    });

    test('counts across a DST change as whole days', () {
      // Spans the late-March / late-October clock changes in most zones.
      expect(calendarDaysAgo(DateTime(2026, 3, 27, 12), DateTime(2026, 3, 30)), 3);
      expect(calendarDaysAgo(DateTime(2026, 10, 24, 12), DateTime(2026, 10, 27)), 3);
    });
  });
}
