import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

class DeleteJournalEntryUseCase {
  final MoodRepository _repository;

  DeleteJournalEntryUseCase(this._repository);

  Future<Either<Failure, void>> call(int id) => _repository.deleteEntry(id);
}
