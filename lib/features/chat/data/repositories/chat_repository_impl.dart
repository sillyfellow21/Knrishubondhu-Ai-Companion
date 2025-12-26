import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiService geminiService;
  final DatabaseService databaseService;
  final Uuid uuid;

  ChatRepositoryImpl({
    required this.geminiService,
    required this.databaseService,
    required this.uuid,
  });

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String userId,
    required String sessionId,
    required String message,
  }) async {
    try {
      Logger.info('Sending text message to AI');

      // Save user message
      final userMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: message,
        sender: 'user',
        createdAt: DateTime.now(),
      );

      await databaseService.insertChatMessage(userMessage.toDatabase());

      // Get AI response
      final aiResponse = await geminiService.sendMessage(message);

      // Save AI response
      final aiMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: aiResponse,
        sender: 'ai',
        createdAt: DateTime.now(),
      );

      await databaseService.insertChatMessage(aiMessage.toDatabase());

      Logger.info('AI response saved successfully');
      return Right(aiMessage);
    } catch (e) {
      Logger.error('Error sending message', error: e);
      return const Left(ServerFailure('বার্তা পাঠাতে ব্যর্থ হয়েছে'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessageWithImage({
    required String userId,
    required String sessionId,
    required String message,
    required String imagePath,
  }) async {
    try {
      Logger.info('Sending message with image to AI');

      // Save user message with image
      final userMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: message,
        sender: 'user',
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );

      await databaseService.insertChatMessage(userMessage.toDatabase());

      // Get AI response with image analysis
      final imageFile = File(imagePath);
      final aiResponse = await geminiService.sendMessageWithImage(
        message: message,
        imageFile: imageFile,
      );

      // Save AI response
      final aiMessage = ChatMessageModel(
        id: uuid.v4(),
        userId: userId,
        sessionId: sessionId,
        message: aiResponse,
        sender: 'ai',
        createdAt: DateTime.now(),
      );

      await databaseService.insertChatMessage(aiMessage.toDatabase());

      Logger.info('AI response with image saved successfully');
      return Right(aiMessage);
    } catch (e) {
      Logger.error('Error sending message with image', error: e);
      return const Left(ServerFailure('ছবি সহ বার্তা পাঠাতে ব্যর্থ হয়েছে'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(
      String sessionId) async {
    try {
      Logger.info('Getting chat history for session: $sessionId');

      final results = await databaseService.getChatHistoryBySessionId(sessionId);

      final messages = results
          .map((data) => ChatMessageModel.fromDatabase(data))
          .toList();

      Logger.info('Retrieved ${messages.length} messages');
      return Right(messages);
    } catch (e) {
      Logger.error('Error getting chat history', error: e);
      return const Left(CacheFailure('চ্যাট ইতিহাস লোড করতে ব্যর্থ'));
    }
  }

  @override
  Future<Either<Failure, void>> saveMessage(ChatMessage message) async {
    try {
      final model = ChatMessageModel(
        id: message.id,
        userId: message.userId,
        sessionId: message.sessionId,
        message: message.message,
        sender: message.sender,
        imagePath: message.imagePath,
        createdAt: message.createdAt,
      );

      await databaseService.insertChatMessage(model.toDatabase());
      return const Right(null);
    } catch (e) {
      Logger.error('Error saving message', error: e);
      return const Left(CacheFailure('বার্তা সংরক্ষণ করতে ব্যর্থ'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await databaseService.deleteChatHistory(sessionId);
      Logger.info('Deleted chat session: $sessionId');
      return const Right(null);
    } catch (e) {
      Logger.error('Error deleting session', error: e);
      return const Left(CacheFailure('চ্যাট মুছতে ব্যর্থ'));
    }
  }
}
