import 'package:ai_therapist_app/features/quotes/domain/entities/saved_quote_entity.dart';

class SavedQuoteModel {
  final String id;
  final String text;

  final DateTime savedAt;

  const SavedQuoteModel({
    required this.id,
    required this.text,
    required this.savedAt,
  });

  factory SavedQuoteModel.fromJson(Map<String, dynamic> json) {
    return SavedQuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'saved_at': savedAt.toIso8601String(),
  };

  SavedQuoteEntity toEntity() => SavedQuoteEntity(
    id: id,
    text: text,
    savedAt: savedAt,
  );
}
