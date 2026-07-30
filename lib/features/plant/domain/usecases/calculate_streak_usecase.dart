import 'package:lueur/core/utils/streak_calculator.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

/// Computes the user's current day-streak from the same entries shown on
/// the journal/home screens, so the streak can never drift from what the
/// user actually sees in their journal.
class CalculateStreakUseCase {
  final MoodRepository _moodRepository;

  CalculateStreakUseCase(this._moodRepository);

  Future<int> call() async {
    final result = await _moodRepository.getHistory();
    return result.fold(
      (_) => 0,
      (entries) => StreakCalculator.calculateConsecutiveStreak(
        entries.map((e) => e.createdAt).toList(),
      ),
    );
  }
}
