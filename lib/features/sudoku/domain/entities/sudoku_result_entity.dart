class SudokuResultEntity {
  final String id;
  final bool won;
  final int mistakes;
  final DateTime completedAt;

  const SudokuResultEntity({
    required this.id,
    required this.won,
    required this.mistakes,
    required this.completedAt,
  });
}
