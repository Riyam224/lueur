import 'package:equatable/equatable.dart';
import 'package:lueur/core/models/mood_entry_type.dart';

class MoodEntryEntity extends Equatable {
  final int id;
  final String userId;
  final String emoji;
  final String thoughts;
  final String aiResponse;
  final DateTime createdAt;

  /// Journal grid customization — a [JournalCardColor] name, or null to
  /// auto-assign a color from the rotation. Never synced to the backend.
  final String? cardColor;

  /// Journal grid customization — pinned entries surface first. Never
  /// synced to the backend.
  final bool pinned;

  /// See [MoodEntryType].
  final String entryType;

  /// Activity-specific data (e.g. `duration_seconds`). Empty for mood_chat.
  final Map<String, dynamic> payload;

  const MoodEntryEntity({
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

  MoodEntryEntity copyWith({String? cardColor, bool? pinned}) => MoodEntryEntity(
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

  @override
  List<Object?> get props => [
        id,
        userId,
        emoji,
        thoughts,
        aiResponse,
        createdAt,
        cardColor,
        pinned,
        entryType,
        payload,
      ];
}