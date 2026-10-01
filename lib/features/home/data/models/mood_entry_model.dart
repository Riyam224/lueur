import 'package:json_annotation/json_annotation.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

part 'mood_entry_model.g.dart';

@JsonSerializable()
class MoodEntryModel {
  /// 0 when the backend sends none (e.g. a fallback reply, which it never
  /// saves).
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(name: 'user_id', defaultValue: '')
  final String userId;

  final String emoji;
  final String thoughts;

  @JsonKey(name: 'ai_response')
  final String aiResponse;

  // The backend sends UTC timestamps; converting here (the single parse
  // point for every entry) means every screen gets local time automatically.
  @JsonKey(name: 'created_at', fromJson: _createdAtFromJson)
  final DateTime createdAt;

  /// Journal grid customization — local-only, never sent to the backend
  /// (see [MoodRepositoryImpl]).
  @JsonKey(name: 'card_color')
  final String? cardColor;

  final bool pinned;

  /// Distinguishes a mood check-in ('mood_chat', default) from an activity
  /// log entry — defaults gracefully so older cached entries still parse.
  @JsonKey(name: 'entry_type')
  final String entryType;

  final Map<String, dynamic> payload;

  /// True when the backend could not reach the AI and answered with a canned
  /// reply. It is shown to the user but must never be cached or journaled,
  /// so it is read from the API only and never written back out.
  @JsonKey(defaultValue: false, includeToJson: false)
  final bool fallback;

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
    this.fallback = false,
  });

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) =>
      _$MoodEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MoodEntryModelToJson(this);

  MoodEntryModel copyWith({int? id, String? cardColor, bool? pinned}) =>
      MoodEntryModel(
        id: id ?? this.id,
        userId: userId,
        emoji: emoji,
        thoughts: thoughts,
        aiResponse: aiResponse,
        createdAt: createdAt,
        cardColor: cardColor ?? this.cardColor,
        pinned: pinned ?? this.pinned,
        entryType: entryType,
        payload: payload,
        fallback: fallback,
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
      isFallback: fallback,
    );
  }
}

DateTime _createdAtFromJson(String value) => DateTime.parse(value).toLocal();
