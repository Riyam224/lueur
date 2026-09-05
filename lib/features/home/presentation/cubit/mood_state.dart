import 'package:equatable/equatable.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

abstract class MoodState extends Equatable {
  const MoodState();

  @override
  List<Object?> get props => [];
}

class MoodInitial extends MoodState {
  const MoodInitial();
}

class MoodLoading extends MoodState {
  const MoodLoading();
}

class MoodHistorySuccess extends MoodState {
  final List<MoodEntryEntity> entries;
  final MoodEntryEntity? justGenerated;

  const MoodHistorySuccess(this.entries, {this.justGenerated});

  @override
  List<Object?> get props => [entries, justGenerated];
}

class MoodError extends MoodState {
  final String message;

  /// True when this failure was caused by no internet connection — the UI
  /// shows a friendly snackbar for this instead of the inline error text.
  final bool offline;

  /// True when a guest tried to talk with Luna — the UI shows a warm
  /// sign-in prompt instead of the generic error copy.
  final bool guestBlocked;

  const MoodError(this.message, {this.offline = false, this.guestBlocked = false});

  @override
  List<Object?> get props => [message, offline, guestBlocked];
}
