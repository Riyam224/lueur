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

  /// Bumped on every failed card action (color/pin/delete) — the entries
  /// list is left untouched, and the screen shows a brief snackbar for
  /// this instead of losing the whole grid. A monotonic counter rather
  /// than a bool so two consecutive failures still produce distinct,
  /// non-Equatable-equal states — otherwise Cubit.emit's built-in dedup
  /// (`state == _state`) would silently drop the second failure and the
  /// snackbar wouldn't show on a retry.
  final int actionFailureCount;

  const JournalGridLoaded(this.entries, {this.actionFailureCount = 0});

  bool get actionFailed => actionFailureCount > 0;

  @override
  List<Object?> get props => [entries, actionFailureCount];
}

final class JournalGridError extends JournalGridState {
  final String message;

  const JournalGridError(this.message);

  @override
  List<Object?> get props => [message];
}
