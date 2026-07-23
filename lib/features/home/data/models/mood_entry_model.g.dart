// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodEntryModel _$MoodEntryModelFromJson(Map<String, dynamic> json) =>
    MoodEntryModel(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String? ?? '',
      emoji: json['emoji'] as String,
      thoughts: json['thoughts'] as String,
      aiResponse: json['ai_response'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      cardColor: json['card_color'] as String?,
      pinned: json['pinned'] as bool? ?? false,
    );

Map<String, dynamic> _$MoodEntryModelToJson(MoodEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'emoji': instance.emoji,
      'thoughts': instance.thoughts,
      'ai_response': instance.aiResponse,
      'created_at': instance.createdAt.toIso8601String(),
      'card_color': instance.cardColor,
      'pinned': instance.pinned,
    };
