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

  /// Hidden by [hideForDelete] but not yet deleted — kept out of every load
  /// so a silent refresh during the undo window can't bring them back.
  final _pendingDeleteIds = <String>{};

  List<SavedDrawingEntity> _visible(List<SavedDrawingEntity> drawings) =>
      drawings.where((d) => !_pendingDeleteIds.contains(d.id)).toList();

  Future<void> loadDrawings() async {
    emit(const SavedDrawingsLoading());
    final result = await _getDrawings();
    if (isClosed) return;
    result.fold(
      (failure) => emit(SavedDrawingsError(failure.message)),
      (drawings) => emit(SavedDrawingsLoaded(_visible(drawings))),
    );
  }

  /// Re-reads without a Loading flash once loaded (e.g. Profile becoming
  /// visible again); a failed silent re-read keeps the current list.
  Future<void> refresh() async {
    if (state is SavedDrawingsLoading) return;
    if (state is! SavedDrawingsLoaded) return loadDrawings();
    final result = await _getDrawings();
    if (isClosed) return;
    result.fold(
      (_) {},
      (drawings) => emit(SavedDrawingsLoaded(_visible(drawings))),
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

  /// Removes [id] from the list right away without deleting it, so the
  /// delete can still be undone; follow with [commitDelete] or [undoDelete].
  void hideForDelete(String id) {
    _pendingDeleteIds.add(id);
    final current = state;
    if (current is SavedDrawingsLoaded) {
      emit(SavedDrawingsLoaded(_visible(current.drawings)));
    }
  }

  /// Brings a hidden drawing back — nothing was deleted yet.
  Future<void> undoDelete(String id) async {
    if (!_pendingDeleteIds.remove(id)) return;
    await refresh();
  }

  /// Deletes a hidden drawing for real once the undo window has passed. Runs
  /// even if this cubit was closed meanwhile (e.g. the user left Profile).
  Future<void> commitDelete(String id) async {
    if (!_pendingDeleteIds.contains(id)) return;
    final result = await _deleteDrawing(id);
    _pendingDeleteIds.remove(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SavedDrawingsError(failure.message)),
      (_) {},
    );
  }
}
