import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

/// Chat Repository Implementation
/// Messages are kept in-memory only (not saved to database)
class ChatRepositoryImpl implements ChatRepository {
  final GeminiService geminiService;
  final Uuid uuid;

  ChatRepositoryImpl({
    required this.geminiService,
    required this.uuid,
  });

  @override
  Future<Either<Failure, (ChatMessage, ChatMessage)>> sendMessage({
    required String userId,
    required String sessionId,
    required String message,
  }) async {
    try {
      Logger.info('Sending text message to AI');

      // Create user message (in-memory only)
      final userMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: message,
        sender: 'user',
        createdAt: DateTime.now(),
      );

      // Get AI response from Gemini
      final aiResponse = await geminiService.sendMessage(message);

      // Create AI message (in-memory only)
      final aiMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: aiResponse,
        sender: 'ai',
        createdAt: DateTime.now(),
      );

      Logger.info('AI response received successfully');
      return Right((userMessage, aiMessage));
    } catch (e) {
      Logger.error('Error sending message', error: e);
      return const Left(ServerFailure(
          'বার্তা পাঠাতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'));
    }
  }

  @override
  Future<Either<Failure, (ChatMessage, ChatMessage)>> sendMessageWithImage({
    required String userId,
    required String sessionId,
    required String message,
    required String imagePath,
  }) async {
    try {
      Logger.info('Sending message with image to AI');

      // Create user message with image (in-memory only)
      final userMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: message,
        sender: 'user',
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );

      // Get AI response with image analysis
      final imageFile = File(imagePath);
      final aiResponse = await geminiService.sendMessageWithImage(
        message: message,
        imageFile: imageFile,
      );

      // Create AI response (in-memory only)
      final aiMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: aiResponse,
        sender: 'ai',
        createdAt: DateTime.now(),
      );

      Logger.info('AI response with image received successfully');
      return Right((userMessage, aiMessage));
    } catch (e) {
      Logger.error('Error sending message with image', error: e);
      return const Left(ServerFailure(
          'ছবি সহ বার্তা পাঠাতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(
      String sessionId) async {
    // No database storage - return empty list
    // Chat history is managed in-memory by the ViewModel
    Logger.info('Chat history is in-memory only, returning empty list');
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> saveMessage(ChatMessage message) async {
    // No database storage - messages are kept in-memory only
    Logger.info('Message storage disabled - messages are in-memory only');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    // Clear Gemini chat history for new session
    geminiService.clearChat();
    Logger.info('Chat session cleared: $sessionId');
    return const Right(null);
  }
}
