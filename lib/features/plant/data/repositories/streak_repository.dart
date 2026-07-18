import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lueur_app/core/networking/api_endpoints.dart';

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
            final date = DateTime.parse(dateStr);
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

      for (final date in dates) {
        final diff = expected.difference(date).inDays;
        if (diff > 1) break;
        streak++;
        expected = date.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (_) {
      return 0;
    }
  }
}
