import 'package:dartz/dartz.dart';
import 'package:lueur_app/core/errors/failures.dart';
import 'package:lueur_app/features/quotes/domain/entities/saved_quote_entity.dart';

abstract class SavedQuotesRepository {
  Future<Either<Failure, List<SavedQuoteEntity>>> getQuotes();
  Future<Either<Failure, SavedQuoteEntity>> saveQuote(
    String text, {
    String? emoji,
    String? thoughts,
  });
  Future<Either<Failure, void>> deleteQuote(String id);
}
