import 'package:dio/dio.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';
import 'package:lueur/features/home/data/models/weekly_letter_model.dart';

class MoodRemoteDatasource {
  final Dio _dio;

  MoodRemoteDatasource(this._dio);

  Future<MoodEntryModel> generateResponse(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.generate, data: body);
    return MoodEntryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MoodEntryModel>> getHistory({required String userId}) async {
    final entries = <MoodEntryModel>[];
    String? nextUrl = ApiEndpoints.history;
    Map<String, dynamic>? queryParameters = {'user_id': userId};

    // The backend may return either a bare list or a DRF-paginated
    // {results, next} envelope — follow every page so the journal shows
    // every day, not just the first page (DRF's default page size).
    while (nextUrl != null) {
      final response = await _dio.get(
        nextUrl,
        queryParameters: queryParameters,
      );
      queryParameters = null;

      final data = response.data;
      final List<dynamic> list;
      if (data is List) {
        list = data;
        nextUrl = null;
      } else {
        final map = data as Map<String, dynamic>;
        list = (map['results'] as List<dynamic>?) ?? [];
        nextUrl = map['next'] as String?;
      }

      entries.addAll(
        list.map((e) => MoodEntryModel.fromJson(e as Map<String, dynamic>)),
      );
    }

    return entries;
  }

  Future<WeeklyLetterModel> getWeeklyLetter() async {
    final response = await _dio.get(ApiEndpoints.weeklyLetter);
    return WeeklyLetterModel.fromJson(response.data as Map<String, dynamic>);
  }
}
