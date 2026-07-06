import 'package:ai_therapist_app/features/plant/domain/entities/plant_stage.dart';
import 'package:equatable/equatable.dart';

abstract class PlantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final PlantStage stage;
  final int streakDays;

  PlantLoaded({
    required this.stage,
    required this.streakDays,
  });

  @override
  List<Object?> get props => [stage, streakDays];
}

class PlantError extends PlantState {
  final String message;
  PlantError(this.message);
  @override
  List<Object?> get props => [message];
}
