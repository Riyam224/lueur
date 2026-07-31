import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';

class SyncPreferredLanguageUseCase {
  final AuthRepository repository;
  const SyncPreferredLanguageUseCase(this.repository);

  Future<Either<Failure, void>> call(String languageCode) {
    return repository.syncPreferredLanguage(languageCode);
  }
}
