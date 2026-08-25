import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

class LogActivityUseCase {
  final MoodRepository _repository;

  LogActivityUseCase(this._repository);

  Future<Either<Failure, MoodEntryEntity>> call({
    required String entryType,
    required Map<String, dynamic> payload,
  }) =>
      _repository.logActivity(entryType: entryType, payload: payload);
}
