import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/quotes/domain/repositories/saved_quotes_repository.dart';

class DeleteQuoteUseCase {
  final SavedQuotesRepository _repository;

  DeleteQuoteUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteQuote(id);
  }
}
