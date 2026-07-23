import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

class ToggleJournalPinUseCase {
  final MoodRepository _repository;

  ToggleJournalPinUseCase(this._repository);

  Future<Either<Failure, MoodEntryEntity>> call({
    required int id,
    required bool pinned,
  }) =>
      _repository.setPinned(id, pinned);
}
