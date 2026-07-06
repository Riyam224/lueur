import 'package:ai_therapist_app/core/errors/failures.dart';
import 'package:ai_therapist_app/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:ai_therapist_app/features/quotes/domain/repositories/saved_quotes_repository.dart';
import 'package:dartz/dartz.dart';

class SaveQuoteUseCase {
  final SavedQuotesRepository _repository;

  SaveQuoteUseCase(this._repository);

  Future<Either<Failure, SavedQuoteEntity>> call(String text) {
    return _repository.saveQuote(text);
  }
}
