import 'package:lueur_app/features/quotes/domain/entities/saved_quote_entity.dart';

class SavedQuoteModel {
  final String id;
  final String text;

  final DateTime savedAt;
  final String? emoji;
  final String? thoughts;

  const SavedQuoteModel({
    required this.id,
    required this.text,
    required this.savedAt,
    this.emoji,
    this.thoughts,
  });

  factory SavedQuoteModel.fromJson(Map<String, dynamic> json) {
    return SavedQuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      emoji: json['emoji'] as String?,
      thoughts: json['thoughts'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'saved_at': savedAt.toIso8601String(),
    'emoji': emoji,
    'thoughts': thoughts,
  };

  SavedQuoteEntity toEntity() => SavedQuoteEntity(
    id: id,
    text: text,
    savedAt: savedAt,
    emoji: emoji,
    thoughts: thoughts,
  );
}
