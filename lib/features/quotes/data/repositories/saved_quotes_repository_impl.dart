import 'package:ai_therapist_app/core/errors/failures.dart';
import 'package:ai_therapist_app/features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import 'package:ai_therapist_app/features/quotes/data/models/saved_quote_model.dart';
import 'package:ai_therapist_app/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:ai_therapist_app/features/quotes/domain/repositories/saved_quotes_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class SavedQuotesRepositoryImpl implements SavedQuotesRepository {
  final SavedQuotesLocalDatasource _local;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger = Logger();

  SavedQuotesRepositoryImpl(this._local, this._firebaseAuth);

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, List<SavedQuoteEntity>>> getQuotes() async {
    try {
      final quotes = _local.getQuotes(userId: _currentUserId);
      return Right(quotes.map((q) => q.toEntity()).toList());
    } catch (e) {
      _logger.e('Failed to load quotes: $e');
      return const Left(NetworkFailure('Failed to load saved quotes'));
    }
  }

  @override
  Future<Either<Failure, SavedQuoteEntity>> saveQuote(String text) async {
    try {
      final quote = SavedQuoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        savedAt: DateTime.now(),
      );
      await _local.saveQuote(quote, userId: _currentUserId);
      return Right(quote.toEntity());
    } catch (e) {
      _logger.e('Failed to save quote: $e');
      return const Left(NetworkFailure('Failed to save quote'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuote(String id) async {
    try {
      await _local.deleteQuote(id, userId: _currentUserId);
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to delete quote: $e');
      return const Left(NetworkFailure('Failed to delete quote'));
    }
  }
}
