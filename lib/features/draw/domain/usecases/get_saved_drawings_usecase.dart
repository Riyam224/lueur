import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/domain/repositories/saved_drawings_repository.dart';

class GetSavedDrawingsUseCase {
  final SavedDrawingsRepository _repository;

  GetSavedDrawingsUseCase(this._repository);

  Future<Either<Failure, List<SavedDrawingEntity>>> call() {
    return _repository.getDrawings();
  }
}
