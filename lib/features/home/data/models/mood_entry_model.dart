import 'package:json_annotation/json_annotation.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

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

  /// Journal grid customization — local-only, never sent to the backend
  /// (the API request body for /generate is built manually and never
  /// includes these fields; see [MoodRepositoryImpl]).
  @JsonKey(name: 'card_color')
  final String? cardColor;

  final bool pinned;

  /// Distinguishes a mood check-in ('mood_chat', the default) from an
  /// activity log entry ('breathing' | 'sudoku' | 'drawing'). Defaults
  /// gracefully so older cached entries without this key still parse.
  @JsonKey(name: 'entry_type')
  final String entryType;

  final Map<String, dynamic> payload;

  const MoodEntryModel({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.thoughts,
    required this.aiResponse,
    required this.createdAt,
    this.cardColor,
    this.pinned = false,
    this.entryType = 'mood_chat',
    this.payload = const {},
  });

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) =>
      _$MoodEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MoodEntryModelToJson(this);

  MoodEntryModel copyWith({String? cardColor, bool? pinned}) => MoodEntryModel(
        id: id,
        userId: userId,
        emoji: emoji,
        thoughts: thoughts,
        aiResponse: aiResponse,
        createdAt: createdAt,
        cardColor: cardColor ?? this.cardColor,
        pinned: pinned ?? this.pinned,
        entryType: entryType,
        payload: payload,
      );

  MoodEntryEntity toEntity() {
    final cleanResponse = aiResponse.replaceAll('[SESSION_END]', '').trim();
    return MoodEntryEntity(
      id: id,
      userId: userId,
      emoji: emoji,
      thoughts: thoughts,
      aiResponse: cleanResponse,
      createdAt: createdAt,
      cardColor: cardColor,
      pinned: pinned,
      entryType: entryType,
      payload: payload,
    );
  }
}
