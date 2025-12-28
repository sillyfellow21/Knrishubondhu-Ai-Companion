import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Send text message and get AI response
  /// Returns tuple of (userMessage, aiMessage)
  Future<Either<Failure, (ChatMessage, ChatMessage)>> sendMessage({
    required String userId,
    required String sessionId,
    required String message,
  });

  /// Send message with image and get AI response
  /// Returns tuple of (userMessage, aiMessage)
  Future<Either<Failure, (ChatMessage, ChatMessage)>> sendMessageWithImage({
    required String userId,
    required String sessionId,
    required String message,
    required String imagePath,
  });

  /// Get chat history for a session (in-memory only)
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String sessionId);

  /// Save message (no-op for in-memory storage)
  Future<Either<Failure, void>> saveMessage(ChatMessage message);

  /// Delete/clear chat session
  Future<Either<Failure, void>> deleteSession(String sessionId);
}
