import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lueur/core/networking/api_endpoints.dart';

class StreakRepository {
  final Dio dio;
  final FirebaseAuth _firebaseAuth;

  StreakRepository(this.dio, this._firebaseAuth);

  Future<int> calculateStreak() async {
    try {
      final userId = _firebaseAuth.currentUser?.uid ?? '';
      final response = await dio.get(
        ApiEndpoints.history,
        queryParameters: {'user_id': userId},
      );

      final List entries = response.data['results'] ?? response.data ?? [];

      if (entries.isEmpty) return 0;

      final dates = entries
          .map((e) {
            final dateStr = e['created_at'] as String;
            final date = DateTime.parse(dateStr).toLocal();
            return DateTime(date.year, date.month, date.day);
          })
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      int streak = 0;
      DateTime expected = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      for (var i = 0; i < dates.length; i++) {
        final date = dates[i];
        final diff = expected.difference(date).inDays;
        // First entry may be today or yesterday (today's entry might not exist yet).
        // Every subsequent entry must land exactly on the expected consecutive day.
        if (i == 0 ? diff > 1 : diff != 0) break;
        streak++;
        expected = date.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (_) {
      return 0;
    }
  }
}
