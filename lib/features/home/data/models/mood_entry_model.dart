import 'package:json_annotation/json_annotation.dart';
import 'package:lueur/core/models/mood_entry_type.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

part 'mood_entry_model.g.dart';

@JsonSerializable()
class MoodEntryModel {
  final int id;

  @JsonKey(name: 'user_id', defaultValue: '')
  final String userId;

  @JsonKey(defaultValue: '')
  final String emoji;

  @JsonKey(defaultValue: '')
  final String thoughts;

  @JsonKey(name: 'ai_response', defaultValue: '')
  final String aiResponse;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Journal grid customization — local-only, never sent to the backend.
  @JsonKey(name: 'card_color')
  final String? cardColor;

  final bool pinned;

  /// See [MoodEntryType]. Defaults gracefully for older cached entries.
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
    this.entryType = MoodEntryType.moodChat,
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
