import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:lueur/features/quotes/domain/repositories/saved_quotes_repository.dart';

class GetSavedQuotesUseCase {
  final SavedQuotesRepository _repository;

  GetSavedQuotesUseCase(this._repository);

  Future<Either<Failure, List<SavedQuoteEntity>>> call() {
    return _repository.getQuotes();
  }
}
