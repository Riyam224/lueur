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

  const JournalGridLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

final class JournalGridError extends JournalGridState {
  final String message;

  const JournalGridError(this.message);

  @override
  List<Object?> get props => [message];
}
