import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';

class MoodCubit extends Cubit<MoodState> {
  final MoodRepository _repository;
  final JournalRefreshSignal _journalRefreshSignal;
  final Logger _logger = Logger();

  List<MoodEntryEntity> _cachedEntries = [];
  int _sessionVersion = 0;

  MoodCubit(this._repository, this._journalRefreshSignal)
      : super(const MoodInitial());

  Future<void> loadEntries() async {
    await getHistory();
  }

  /// Clears in-memory entries and resets state to initial.
  /// Call this when the active user changes so the new user starts fresh.
  void clearEntries() {
    _sessionVersion++;
    _cachedEntries = [];
    emit(const MoodInitial());
  }

  Future<void> generateResponse({
    required String emoji,
    required String thoughts,
  }) async {
    final sessionVersion = _sessionVersion;
    emit(const MoodLoading());
    _logger.i('MoodCubit: generating response...');

    final result = await _repository.generateResponse(
      emoji: emoji,
      thoughts: thoughts,
    );
    if (isClosed || sessionVersion != _sessionVersion) return;

    result.fold(
      (failure) {
        _logger.e('MoodCubit error: ${failure.message}');
        emit(
          MoodError(
            failure.message,
            offline: failure is NetworkOfflineFailure,
            guestBlocked: failure is GuestSignInRequiredFailure,
          ),
        );
      },
      (entry) {
        _logger.i('MoodCubit: success — entry id: ${entry.id}');
        _cachedEntries = [entry, ..._cachedEntries];
        emit(MoodHistorySuccess(_cachedEntries, justGenerated: entry));
        _journalRefreshSignal.bump();
      },
    );
  }

  Future<void> addLocalEntry({
    required String emoji,
    required String thoughts,
  }) async {
    final sessionVersion = _sessionVersion;
    _logger.i('MoodCubit: saving local entry...');

    final result = await _repository.addLocalEntry(
      emoji: emoji,
      thoughts: thoughts,
    );
    if (isClosed || sessionVersion != _sessionVersion) return;

    result.fold(
      (failure) {
        _logger.e('MoodCubit local save error: ${failure.message}');
        emit(
          MoodError(failure.message, offline: failure is NetworkOfflineFailure),
        );
      },
      (entry) {
        _logger.i('MoodCubit local save success — entry id: ${entry.id}');
        _cachedEntries = [entry, ..._cachedEntries];
        emit(MoodHistorySuccess(_cachedEntries, justGenerated: entry));
        _journalRefreshSignal.bump();
      },
    );
  }

  Future<void> deleteEntry(int id) async {
    final result = await _repository.deleteEntry(id);
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.e('MoodCubit delete error: ${failure.message}');
        emit(
          MoodError(failure.message, offline: failure is NetworkOfflineFailure),
        );
      },
      (_) {
        _cachedEntries = _cachedEntries.where((e) => e.id != id).toList();
        emit(MoodHistorySuccess(_cachedEntries));
        _journalRefreshSignal.bump();
      },
    );
  }

  Future<void> deleteAllEntries() async {
    final result = await _repository.deleteAllEntries();
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.e('MoodCubit delete all error: ${failure.message}');
        emit(
          MoodError(failure.message, offline: failure is NetworkOfflineFailure),
        );
      },
      (_) {
        _cachedEntries = [];
        emit(const MoodHistorySuccess([]));
        _journalRefreshSignal.bump();
      },
    );
  }

  Future<void> getHistory() async {
    final sessionVersion = _sessionVersion;
    emit(const MoodLoading());
    _logger.i('MoodCubit: fetching history...');

    final result = await _repository.getHistory();
    if (isClosed || sessionVersion != _sessionVersion) return;

    result.fold(
      (failure) {
        _logger.e('MoodCubit history error: ${failure.message}');
        emit(
          MoodError(failure.message, offline: failure is NetworkOfflineFailure),
        );
      },
      (entries) {
        _logger.i('MoodCubit: ${entries.length} entries loaded');
        _cachedEntries = entries;
        emit(MoodHistorySuccess(entries));
      },
    );
  }
}
