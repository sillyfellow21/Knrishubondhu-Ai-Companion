import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/gemini_service.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/send_message_with_image_usecase.dart';

/// Gemini Service Provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService.instance;
});

/// UUID Provider
final chatUuidProvider = Provider<Uuid>((ref) => const Uuid());

/// Chat Repository Provider (no database dependency)
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    geminiService: ref.watch(geminiServiceProvider),
    uuid: ref.watch(chatUuidProvider),
  );
});

/// Send Message Use Case Provider
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

/// Send Message With Image Use Case Provider
final sendMessageWithImageUseCaseProvider =
    Provider<SendMessageWithImageUseCase>((ref) {
  return SendMessageWithImageUseCase(ref.watch(chatRepositoryProvider));
});

/// Get Chat History Use Case Provider
final getChatHistoryUseCaseProvider = Provider<GetChatHistoryUseCase>((ref) {
  return GetChatHistoryUseCase(ref.watch(chatRepositoryProvider));
});
