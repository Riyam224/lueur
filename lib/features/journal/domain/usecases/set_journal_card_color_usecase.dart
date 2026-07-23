import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

class SetJournalCardColorUseCase {
  final MoodRepository _repository;

  SetJournalCardColorUseCase(this._repository);

  Future<Either<Failure, MoodEntryEntity>> call({
    required int id,
    required String cardColor,
  }) =>
      _repository.setCardColor(id, cardColor);
}
