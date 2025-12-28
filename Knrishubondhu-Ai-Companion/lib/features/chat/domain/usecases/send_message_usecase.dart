import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  /// Returns tuple of (userMessage, aiMessage)
  Future<Either<Failure, (ChatMessage, ChatMessage)>> call({
    required String userId,
    required String sessionId,
    required String message,
  }) async {
    return await repository.sendMessage(
      userId: userId,
      sessionId: sessionId,
      message: message,
    );
  }
}
