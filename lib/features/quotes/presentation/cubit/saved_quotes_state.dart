import 'package:ai_therapist_app/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SavedQuotesState extends Equatable {
  const SavedQuotesState();

  @override
  List<Object?> get props => [];
}

class SavedQuotesInitial extends SavedQuotesState {
  const SavedQuotesInitial();
}

class SavedQuotesLoading extends SavedQuotesState {
  const SavedQuotesLoading();
}

class SavedQuotesLoaded extends SavedQuotesState {
  final List<SavedQuoteEntity> quotes;

  const SavedQuotesLoaded(this.quotes);

  @override
  List<Object?> get props => [quotes];
}

class SavedQuotesError extends SavedQuotesState {
  final String message;

  const SavedQuotesError(this.message);

  @override
  List<Object?> get props => [message];
}
