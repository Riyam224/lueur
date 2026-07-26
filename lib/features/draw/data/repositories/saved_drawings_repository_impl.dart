import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/draw/data/datasources/saved_drawings_local_datasource.dart';
import 'package:lueur/features/draw/data/models/saved_drawing_model.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/domain/repositories/saved_drawings_repository.dart';

class SavedDrawingsRepositoryImpl implements SavedDrawingsRepository {
  final SavedDrawingsLocalDatasource _local;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger = Logger();

  SavedDrawingsRepositoryImpl(this._local, this._firebaseAuth);

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, List<SavedDrawingEntity>>> getDrawings() async {
    try {
      final drawings = _local.getDrawings(userId: _currentUserId);
      return Right(drawings.map((d) => d.toEntity()).toList());
    } catch (e) {
      _logger.e('Failed to load saved drawings: $e');
      return const Left(NetworkFailure('Failed to load saved drawings'));
    }
  }

  @override
  Future<Either<Failure, SavedDrawingEntity>> saveDrawing(
    List<SavedDrawingPathEntity> paths,
  ) async {
    try {
      final drawing = SavedDrawingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        paths: paths
            .map(
              (p) => SavedDrawingPathModel(
                colorArgb: p.colorArgb,
                points: p.points,
              ),
            )
            .toList(),
        createdAt: DateTime.now(),
      );
      await _local.saveDrawing(drawing, userId: _currentUserId);
      return Right(drawing.toEntity());
    } catch (e) {
      _logger.e('Failed to save drawing: $e');
      return const Left(NetworkFailure('Failed to save drawing'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDrawing(String id) async {
    try {
      await _local.deleteDrawing(id, userId: _currentUserId);
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to delete drawing: $e');
      return const Left(NetworkFailure('Failed to delete drawing'));
    }
  }
}
