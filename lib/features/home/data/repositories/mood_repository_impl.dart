import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/home/data/datasources/mood_remote_datasource.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodRemoteDatasource _remote;
  final MoodLocalDatasource _local;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger = Logger();

  MoodRepositoryImpl(this._remote, this._local, this._firebaseAuth);

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  }) async {
    try {
      _logger.i('Generating response for emoji: $emoji');

      final MoodEntryModel model = await _remote.generateResponse({
        'user_id': _currentUserId,
        'emoji': emoji,
        'thoughts': thoughts,
      });

      await _local.addEntry(model, userId: _currentUserId);

      _logger.i('Response generated and cached: id=${model.id}');
      return Right(model.toEntity());
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      _logger.e('Unexpected error: $e');
      return Left(NetworkFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MoodEntryEntity>> addLocalEntry({
    required String emoji,
    required String thoughts,
  }) async {
    try {
      final localEntry = MoodEntryModel(
        id: 0,
        userId: _currentUserId,
        emoji: emoji,
        thoughts: thoughts,
        aiResponse: '',
        createdAt: DateTime.now(),
      );

      await _local.addEntry(localEntry, userId: _currentUserId);
      _logger.i('Local entry cached');
      return Right(localEntry.toEntity());
    } catch (e) {
      _logger.e('Failed to cache local entry: $e');
      return const Left(NetworkFailure('Failed to save entry locally'));
    }
  }

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() async {
    try {
      _logger.i('Fetching mood history from API...');

      // The backend scopes this response to the authenticated user via the
      // Bearer token, so no client-side re-filter is needed here. (A prior
      // filter compared the Firebase UID against the backend's own numeric
      // user id, which never match — it silently dropped every entry.)
      final List<MoodEntryModel> models =
          await _remote.getHistory(userId: _currentUserId);

      // The backend doesn't know about cardColor/pinned — carry over the
      // locally cached values so a refresh doesn't wipe journal grid
      // customization back to defaults.
      final merged = _mergeLocalOnlyFields(models);

      await _local.cacheHistory(merged, userId: _currentUserId);

      _logger.i('Fetched ${merged.length} entries for current user');
      return Right(merged.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      _logger.w('API failed, falling back to cache: ${e.message}');
      return _fallbackToCache(
        ServerFailure(e.message ?? 'Server error occurred'),
      );
    } catch (e) {
      _logger.w('Unexpected error, falling back to cache: $e');
      return _fallbackToCache(NetworkFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(int id) async {
    try {
      await _local.deleteEntry(id, userId: _currentUserId);
      _logger.i('Entry deleted from cache: id=$id');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to delete entry: $e');
      return const Left(NetworkFailure('Failed to delete entry'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllEntries() async {
    try {
      await _local.deleteAllEntries(userId: _currentUserId);
      _logger.i('All entries deleted from cache');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to delete all entries: $e');
      return const Left(NetworkFailure('Failed to delete all entries'));
    }
  }

  Either<Failure, List<MoodEntryEntity>> _fallbackToCache(Failure failure) {
    final cached = _local.getCachedHistory(userId: _currentUserId);
    if (cached.isNotEmpty) {
      _logger.i('Returning ${cached.length} cached entries for current user');
      return Right(cached.map((m) => m.toEntity()).toList());
    }
    return Left(failure);
  }

  List<MoodEntryModel> _mergeLocalOnlyFields(List<MoodEntryModel> remoteModels) {
    final cachedById = {
      for (final entry in _local.getCachedHistory(userId: _currentUserId))
        entry.id: entry,
    };

    return remoteModels.map((model) {
      final cached = cachedById[model.id];
      if (cached == null) return model;
      return model.copyWith(cardColor: cached.cardColor, pinned: cached.pinned);
    }).toList();
  }

  @override
  Future<Either<Failure, MoodEntryEntity>> setCardColor(
    int id,
    String cardColor,
  ) async {
    try {
      final updated =
          await _local.setCardColor(id, cardColor, userId: _currentUserId);
      if (updated == null) {
        return const Left(NetworkFailure('Entry not found'));
      }
      return Right(updated.toEntity());
    } catch (e) {
      _logger.e('Failed to update entry color: $e');
      return Left(NetworkFailure('Failed to update entry color: $e'));
    }
  }

  @override
  Future<Either<Failure, MoodEntryEntity>> setPinned(int id, bool pinned) async {
    try {
      final updated = await _local.setPinned(id, pinned, userId: _currentUserId);
      if (updated == null) {
        return const Left(NetworkFailure('Entry not found'));
      }
      return Right(updated.toEntity());
    } catch (e) {
      _logger.e('Failed to update entry: $e');
      return Left(NetworkFailure('Failed to update entry: $e'));
    }
  }
}
