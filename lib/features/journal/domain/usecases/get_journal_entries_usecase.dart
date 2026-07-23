import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

class GetJournalEntriesUseCase {
  final MoodRepository _repository;

  GetJournalEntriesUseCase(this._repository);

  Future<Either<Failure, List<MoodEntryEntity>>> call() =>
      _repository.getHistory();
}
