import 'package:equatable/equatable.dart';

enum SudokuStatus { playing, won, lost }

class SudokuState extends Equatable {
  final List<List<int>> values;
  final List<List<bool>> given;
  final List<List<bool>> conflicts;
  final int? selectedRow;
  final int? selectedCol;
  final int mistakes;
  final SudokuStatus status;

  const SudokuState({
    required this.values,
    required this.given,
    required this.conflicts,
    required this.mistakes,
    required this.status,
    this.selectedRow,
    this.selectedCol,
  });

  SudokuState copyWith({
    List<List<int>>? values,
    List<List<bool>>? conflicts,
    int? selectedRow,
    int? selectedCol,
    bool clearSelection = false,
    int? mistakes,
    SudokuStatus? status,
  }) {
    return SudokuState(
      values: values ?? this.values,
      given: given,
      conflicts: conflicts ?? this.conflicts,
      selectedRow: clearSelection ? null : (selectedRow ?? this.selectedRow),
      selectedCol: clearSelection ? null : (selectedCol ?? this.selectedCol),
      mistakes: mistakes ?? this.mistakes,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [values, given, conflicts, selectedRow, selectedCol, mistakes, status];
}
