import 'package:dio/dio.dart';
import 'package:lueur_app/core/networking/api_endpoints.dart';
import 'package:lueur_app/features/home/data/models/mood_entry_model.dart';
import 'package:lueur_app/features/home/data/models/weekly_letter_model.dart';

class MoodRemoteDatasource {
  final Dio _dio;

  MoodRemoteDatasource(this._dio);

  Future<MoodEntryModel> generateResponse(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.generate, data: body);
    return MoodEntryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MoodEntryModel>> getHistory({required String userId}) async {
    final response = await _dio.get(
      ApiEndpoints.history,
      queryParameters: {'user_id': userId},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => MoodEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeeklyLetterModel> getWeeklyLetter() async {
    final response = await _dio.get(ApiEndpoints.weeklyLetter);
    return WeeklyLetterModel.fromJson(response.data as Map<String, dynamic>);
  }
}
