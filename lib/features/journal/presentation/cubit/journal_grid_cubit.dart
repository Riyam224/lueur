import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/domain/usecases/delete_journal_entry_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/get_journal_entries_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/set_journal_card_color_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/toggle_journal_pin_usecase.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';

class JournalGridCubit extends Cubit<JournalGridState> {
  final GetJournalEntriesUseCase _getEntriesUseCase;
  final SetJournalCardColorUseCase _setCardColorUseCase;
  final ToggleJournalPinUseCase _togglePinUseCase;
  final DeleteJournalEntryUseCase _deleteEntryUseCase;

  JournalGridCubit({
    required GetJournalEntriesUseCase getEntriesUseCase,
    required SetJournalCardColorUseCase setCardColorUseCase,
    required ToggleJournalPinUseCase togglePinUseCase,
    required DeleteJournalEntryUseCase deleteEntryUseCase,
  })  : _getEntriesUseCase = getEntriesUseCase,
        _setCardColorUseCase = setCardColorUseCase,
        _togglePinUseCase = togglePinUseCase,
        _deleteEntryUseCase = deleteEntryUseCase,
        super(const JournalGridInitial());

  Future<void> loadEntries() async {
    if (isClosed) return;
    emit(const JournalGridLoading());
    final result = await _getEntriesUseCase();
    if (isClosed) return;
    result.fold(
      (failure) => emit(JournalGridError(failure.message)),
      (entries) => emit(JournalGridLoaded(entries)),
    );
  }

  /// Updates just this one entry's color, without refetching the list.
  Future<void> setCardColor(int id, String cardColor) async {
    final current = state;
    if (current is! JournalGridLoaded) return;

    final result = await _setCardColorUseCase(id: id, cardColor: cardColor);
    if (isClosed) return;
    result.fold(
      (failure) => emit(JournalGridError(failure.message)),
      (updated) => emit(JournalGridLoaded(_replace(current.entries, updated))),
    );
  }

  /// Updates just this one entry's pinned flag, without refetching the list.
  Future<void> togglePinned(int id, bool pinned) async {
    final current = state;
    if (current is! JournalGridLoaded) return;

    final result = await _togglePinUseCase(id: id, pinned: pinned);
    if (isClosed) return;
    result.fold(
      (failure) => emit(JournalGridError(failure.message)),
      (updated) => emit(JournalGridLoaded(_replace(current.entries, updated))),
    );
  }

  /// Removes just this one entry from the current list, without refetching.
  Future<void> deleteEntry(int id) async {
    final current = state;
    if (current is! JournalGridLoaded) return;

    final result = await _deleteEntryUseCase(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(JournalGridError(failure.message)),
      (_) => emit(
        JournalGridLoaded(
          current.entries.where((e) => e.id != id).toList(),
        ),
      ),
    );
  }

  List<MoodEntryEntity> _replace(
    List<MoodEntryEntity> entries,
    MoodEntryEntity updated,
  ) =>
      entries.map((e) => e.id == updated.id ? updated : e).toList();
}
