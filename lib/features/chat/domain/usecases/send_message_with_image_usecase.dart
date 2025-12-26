import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageWithImageUseCase {
  final ChatRepository repository;

  SendMessageWithImageUseCase(this.repository);

  Future<Either<Failure, ChatMessage>> call({
    required String userId,
    required String sessionId,
    required String message,
    required String imagePath,
  }) async {
    return await repository.sendMessageWithImage(
      userId: userId,
      sessionId: sessionId,
      message: message,
      imagePath: imagePath,
    );
  }
}
