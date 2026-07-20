import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/quotes/domain/usecases/delete_quote_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/get_saved_quotes_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/save_quote_usecase.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_state.dart';

class SavedQuotesCubit extends Cubit<SavedQuotesState> {
  final GetSavedQuotesUseCase _getQuotes;
  final SaveQuoteUseCase _saveQuote;
  final DeleteQuoteUseCase _deleteQuote;

  SavedQuotesCubit(
    this._getQuotes,
    this._saveQuote,
    this._deleteQuote,
  ) : super(const SavedQuotesInitial());

  Future<void> loadQuotes() async {
    emit(const SavedQuotesLoading());
    final result = await _getQuotes();
    result.fold(
      (failure) => emit(SavedQuotesError(failure.message)),
      (quotes) => emit(SavedQuotesLoaded(quotes)),
    );
  }

  Future<void> saveQuote(String text, {String? emoji, String? thoughts}) async {
    final result = await _saveQuote(text, emoji: emoji, thoughts: thoughts);
    result.fold(
      (failure) => emit(SavedQuotesError(failure.message)),
      (_) => loadQuotes(),
    );
  }

  Future<void> deleteQuote(String id) async {
    final result = await _deleteQuote(id);
    result.fold(
      (failure) => emit(SavedQuotesError(failure.message)),
      (_) => loadQuotes(),
    );
  }
}
