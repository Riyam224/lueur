import 'package:equatable/equatable.dart';

enum SudokuStatus { playing, won, lost }

enum SudokuInputMode { normal, candidate }

class SudokuState extends Equatable {
  final List<List<int>> values;
  final List<List<bool>> given;
  final List<List<bool>> conflicts;
  final List<List<Set<int>>> candidates;
  final int? selectedRow;
  final int? selectedCol;
  final SudokuInputMode mode;
  final int mistakes;
  final int elapsedSeconds;
  final bool isPaused;
  final bool autoCandidateMode;
  final bool canUndo;
  final SudokuStatus status;
  final bool resultSaveFailed;

  const SudokuState({
    required this.values,
    required this.given,
    required this.conflicts,
    required this.candidates,
    required this.mode,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.autoCandidateMode,
    required this.canUndo,
    required this.status,
    this.selectedRow,
    this.selectedCol,
    this.resultSaveFailed = false,
  });

  SudokuState copyWith({
    List<List<int>>? values,
    List<List<bool>>? conflicts,
    List<List<Set<int>>>? candidates,
    int? selectedRow,
    int? selectedCol,
    SudokuInputMode? mode,
    int? mistakes,
    int? elapsedSeconds,
    bool? isPaused,
    bool? autoCandidateMode,
    bool? canUndo,
    SudokuStatus? status,
    bool? resultSaveFailed,
  }) {
    return SudokuState(
      values: values ?? this.values,
      given: given,
      conflicts: conflicts ?? this.conflicts,
      candidates: candidates ?? this.candidates,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      mode: mode ?? this.mode,
      mistakes: mistakes ?? this.mistakes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isPaused: isPaused ?? this.isPaused,
      autoCandidateMode: autoCandidateMode ?? this.autoCandidateMode,
      canUndo: canUndo ?? this.canUndo,
      status: status ?? this.status,
      resultSaveFailed: resultSaveFailed ?? this.resultSaveFailed,
    );
  }

  @override
  List<Object?> get props => [
    values,
    given,
    conflicts,
    candidates,
    selectedRow,
    selectedCol,
    mode,
    mistakes,
    elapsedSeconds,
    isPaused,
    autoCandidateMode,
    canUndo,
    status,
    resultSaveFailed,
  ];
}
