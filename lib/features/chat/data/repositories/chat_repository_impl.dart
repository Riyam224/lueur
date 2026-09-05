import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger = Logger();

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  bool get _isGuest => _firebaseAuth.currentUser == null;

  @override
  Future<Either<Failure, String>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async {
    if (_isGuest) {
      _logger.i('Blocked guest attempt to talk with Luna — no network call made');
      return const Left(GuestSignInRequiredFailure());
    }

    try {
      final reply = await remoteDataSource.sendMessage(
        userId: userId,
        emoji: emoji,
        thoughts: thoughts,
        history: history,
      );
      return Right(reply);
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkOfflineFailure());
      }
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      _logger.e('Unexpected error: $e');
      return Left(NetworkFailure('Unexpected error: $e'));
    }
  }
}
