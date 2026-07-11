import 'package:ai_therapist_app/core/errors/failures.dart';
import 'package:ai_therapist_app/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:dartz/dartz.dart';

abstract class SavedQuotesRepository {
  Future<Either<Failure, List<SavedQuoteEntity>>> getQuotes();
  Future<Either<Failure, SavedQuoteEntity>> saveQuote(
    String text, {
    String? emoji,
    String? thoughts,
  });
  Future<Either<Failure, void>> deleteQuote(String id);
}
