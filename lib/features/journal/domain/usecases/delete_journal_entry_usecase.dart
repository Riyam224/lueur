import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

class DeleteJournalEntryUseCase {
  final MoodRepository _repository;

  DeleteJournalEntryUseCase(this._repository);

  Future<Either<Failure, void>> call(MoodEntryEntity entry) =>
      _repository.deleteEntry(entry);
}
