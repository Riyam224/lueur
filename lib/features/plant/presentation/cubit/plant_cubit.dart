import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/plant/domain/entities/plant_stage.dart';
import 'package:lueur/features/plant/domain/usecases/calculate_streak_usecase.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';

class PlantCubit extends Cubit<PlantState> {
  final CalculateStreakUseCase _calculateStreakUseCase;

  PlantCubit(this._calculateStreakUseCase) : super(PlantInitial());

  Future<void> loadPlant() async {
    emit(PlantLoading());
    try {
      final streak = await _calculateStreakUseCase();
      emit(PlantLoaded(
        stage: PlantStage.fromStreak(streak),
        streakDays: streak,
      ),);
    } catch (_) {
      emit(PlantLoaded(
        stage: PlantStage.seed,
        streakDays: 0,
      ),);
    }
  }
}
