import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/domain/repositories/saved_drawings_repository.dart';

class SaveDrawingUseCase {
  final SavedDrawingsRepository _repository;

  SaveDrawingUseCase(this._repository);

  Future<Either<Failure, SavedDrawingEntity>> call(
    List<SavedDrawingPathEntity> paths,
  ) {
    return _repository.saveDrawing(paths);
  }
}
