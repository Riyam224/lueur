import 'package:dartz/dartz.dart';
import 'package:lueur_app/core/errors/failures.dart';
import 'package:lueur_app/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:lueur_app/features/quotes/domain/repositories/saved_quotes_repository.dart';

class SaveQuoteUseCase {
  final SavedQuotesRepository _repository;

  SaveQuoteUseCase(this._repository);

  Future<Either<Failure, SavedQuoteEntity>> call(
    String text, {
    String? emoji,
    String? thoughts,
  }) {
    return _repository.saveQuote(text, emoji: emoji, thoughts: thoughts);
  }
}
