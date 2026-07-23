import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

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

  /// Journal grid card color — local-only, never synced to the backend.
  Future<Either<Failure, MoodEntryEntity>> setCardColor(int id, String cardColor);

  /// Journal grid pinned flag — local-only, never synced to the backend.
  Future<Either<Failure, MoodEntryEntity>> setPinned(int id, bool pinned);
}
