import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';

abstract class SavedDrawingsRepository {
  Future<Either<Failure, List<SavedDrawingEntity>>> getDrawings();
  Future<Either<Failure, SavedDrawingEntity>> saveDrawing(
    List<SavedDrawingPathEntity> paths,
  );
  Future<Either<Failure, void>> deleteDrawing(String id);
}
