import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

/// Computes the user's current day-streak from the same entries shown on
/// the journal/home screens, so the streak can never drift from what the
/// user actually sees in their journal.
class CalculateStreakUseCase {
  final MoodRepository _moodRepository;

  CalculateStreakUseCase(this._moodRepository);

  Future<int> call() async {
    final result = await _moodRepository.getHistory();
    return result.fold((_) => 0, _calculate);
  }

  int _calculate(List<MoodEntryEntity> entries) {
    if (entries.isEmpty) return 0;

    final dates = entries
        .map((e) {
          final local = e.createdAt.toLocal();
          return DateTime(local.year, local.month, local.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    var expected = DateTime(today.year, today.month, today.day);
    var streak = 0;

    for (var i = 0; i < dates.length; i++) {
      final date = dates[i];
      final diff = expected.difference(date).inDays;
      // The most recent entry may be today or yesterday (today's entry might
      // not exist yet). Every entry after that must land exactly on the
      // expected consecutive day, or the streak is broken.
      if (i == 0 ? diff > 1 : diff != 0) break;
      streak++;
      expected = date.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
