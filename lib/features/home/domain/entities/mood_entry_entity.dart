import 'package:equatable/equatable.dart';

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

  const MoodEntryEntity({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.thoughts,
    required this.aiResponse,
    required this.createdAt,
    this.cardColor,
    this.pinned = false,
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
      );

  @override
  List<Object?> get props =>
      [id, userId, emoji, thoughts, aiResponse, createdAt, cardColor, pinned];
}