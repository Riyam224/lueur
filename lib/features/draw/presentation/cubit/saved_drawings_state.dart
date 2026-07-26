import 'package:equatable/equatable.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';

abstract class SavedDrawingsState extends Equatable {
  const SavedDrawingsState();

  @override
  List<Object?> get props => [];
}

class SavedDrawingsInitial extends SavedDrawingsState {
  const SavedDrawingsInitial();
}

class SavedDrawingsLoading extends SavedDrawingsState {
  const SavedDrawingsLoading();
}

class SavedDrawingsLoaded extends SavedDrawingsState {
  final List<SavedDrawingEntity> drawings;

  const SavedDrawingsLoaded(this.drawings);

  @override
  List<Object?> get props => [drawings];
}

class SavedDrawingsError extends SavedDrawingsState {
  final String message;

  const SavedDrawingsError(this.message);

  @override
  List<Object?> get props => [message];
}
