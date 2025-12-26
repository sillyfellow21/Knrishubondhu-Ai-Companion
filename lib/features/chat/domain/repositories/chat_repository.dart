import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Send text message and get AI response
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String userId,
    required String sessionId,
    required String message,
  });

  /// Send message with image and get AI response
  Future<Either<Failure, ChatMessage>> sendMessageWithImage({
    required String userId,
    required String sessionId,
    required String message,
    required String imagePath,
  });

  /// Get chat history for a session
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String sessionId);

  /// Save message to local database
  Future<Either<Failure, void>> saveMessage(ChatMessage message);

  /// Delete chat session
  Future<Either<Failure, void>> deleteSession(String sessionId);
}
