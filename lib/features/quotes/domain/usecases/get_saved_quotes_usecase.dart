import 'package:ai_therapist_app/core/errors/failures.dart';
import 'package:ai_therapist_app/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:ai_therapist_app/features/quotes/domain/repositories/saved_quotes_repository.dart';
import 'package:dartz/dartz.dart';

class GetSavedQuotesUseCase {
  final SavedQuotesRepository _repository;

  GetSavedQuotesUseCase(this._repository);

  Future<Either<Failure, List<SavedQuoteEntity>>> call() {
    return _repository.getQuotes();
  }
}
