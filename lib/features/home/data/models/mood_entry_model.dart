import 'package:ai_therapist_app/features/home/domain/entities/mood_entry_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mood_entry_model.g.dart';

@JsonSerializable()
class MoodEntryModel {
  final int id;

  @JsonKey(name: 'user_id', defaultValue: '')
  final String userId;

  final String emoji;
  final String thoughts;

  @JsonKey(name: 'ai_response')
  final String aiResponse;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const MoodEntryModel({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.thoughts,
    required this.aiResponse,
    required this.createdAt,
  });

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) =>
      _$MoodEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MoodEntryModelToJson(this);

  MoodEntryEntity toEntity() => MoodEntryEntity(
        id: id,
        userId: userId,
        emoji: emoji,
        thoughts: thoughts,
        aiResponse: aiResponse,
        createdAt: createdAt,
      );
}
