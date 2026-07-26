import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/draw/domain/repositories/saved_drawings_repository.dart';

class DeleteDrawingUseCase {
  final SavedDrawingsRepository _repository;

  DeleteDrawingUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteDrawing(id);
  }
}
