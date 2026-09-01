import 'package:equatable/equatable.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

sealed class JournalGridState extends Equatable {
  const JournalGridState();

  @override
  List<Object?> get props => [];
}

final class JournalGridInitial extends JournalGridState {
  const JournalGridInitial();
}

final class JournalGridLoading extends JournalGridState {
  const JournalGridLoading();
}

final class JournalGridLoaded extends JournalGridState {
  final List<MoodEntryEntity> entries;

  /// One-shot signal that the last card action (color/pin/delete) failed to
  /// save — the entries list is left untouched, and the screen shows a
  /// brief snackbar for this instead of losing the whole grid.
  final bool actionFailed;

  const JournalGridLoaded(this.entries, {this.actionFailed = false});

  @override
  List<Object?> get props => [entries, actionFailed];
}

final class JournalGridError extends JournalGridState {
  final String message;

  const JournalGridError(this.message);

  @override
  List<Object?> get props => [message];
}
