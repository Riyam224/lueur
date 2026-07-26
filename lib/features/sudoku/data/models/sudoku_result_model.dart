import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';

class SudokuResultModel {
  final String id;
  final bool won;
  final int mistakes;
  final DateTime completedAt;

  const SudokuResultModel({
    required this.id,
    required this.won,
    required this.mistakes,
    required this.completedAt,
  });

  factory SudokuResultModel.fromJson(Map<String, dynamic> json) {
    return SudokuResultModel(
      id: json['id'] as String,
      won: json['won'] as bool,
      mistakes: json['mistakes'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'won': won,
    'mistakes': mistakes,
    'completed_at': completedAt.toIso8601String(),
  };

  SudokuResultEntity toEntity() => SudokuResultEntity(
    id: id,
    won: won,
    mistakes: mistakes,
    completedAt: completedAt,
  );
}
