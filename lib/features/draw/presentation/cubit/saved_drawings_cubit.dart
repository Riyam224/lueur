import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/domain/usecases/delete_drawing_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/get_saved_drawings_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/save_drawing_usecase.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_state.dart';

class SavedDrawingsCubit extends Cubit<SavedDrawingsState> {
  final GetSavedDrawingsUseCase _getDrawings;
  final SaveDrawingUseCase _saveDrawing;
  final DeleteDrawingUseCase _deleteDrawing;

  SavedDrawingsCubit(
    this._getDrawings,
    this._saveDrawing,
    this._deleteDrawing,
  ) : super(const SavedDrawingsInitial());

  Future<void> loadDrawings() async {
    emit(const SavedDrawingsLoading());
    final result = await _getDrawings();
    if (isClosed) return;
    result.fold(
      (failure) => emit(SavedDrawingsError(failure.message)),
      (drawings) => emit(SavedDrawingsLoaded(drawings)),
    );
  }

  Future<void> saveCurrent(List<SavedDrawingPathEntity> paths) async {
    final result = await _saveDrawing(paths);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SavedDrawingsError(failure.message)),
      (_) => loadDrawings(),
    );
  }

  Future<void> deleteDrawing(String id) async {
    final result = await _deleteDrawing(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SavedDrawingsError(failure.message)),
      (_) => loadDrawings(),
    );
  }
}
