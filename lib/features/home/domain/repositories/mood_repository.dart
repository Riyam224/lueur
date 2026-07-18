import 'package:dartz/dartz.dart';
import 'package:lueur_app/core/errors/failures.dart';
import 'package:lueur_app/features/home/domain/entities/mood_entry_entity.dart';

abstract class MoodRepository {
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  });

  Future<Either<Failure, MoodEntryEntity>> addLocalEntry({
    required String emoji,
    required String thoughts,
  });

  Future<Either<Failure, List<MoodEntryEntity>>> getHistory();

  Future<Either<Failure, void>> deleteEntry(int id);

  Future<Either<Failure, void>> deleteAllEntries();
}
