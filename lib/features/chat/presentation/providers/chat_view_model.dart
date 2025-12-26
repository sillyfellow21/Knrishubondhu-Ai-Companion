import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/send_message_with_image_usecase.dart';
import 'chat_providers.dart';
import 'chat_state.dart';

/// Chat View Model Provider
final chatViewModelProvider =
    StateNotifierProvider.family<ChatViewModel, ChatState, String>(
  (ref, sessionId) {
    return ChatViewModel(
      sessionId: sessionId,
      sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
      sendMessageWithImageUseCase: ref.watch(sendMessageWithImageUseCaseProvider),
      getChatHistoryUseCase: ref.watch(getChatHistoryUseCaseProvider),
      uuid: ref.watch(chatUuidProvider),
    );
  },
);

/// Chat View Model
class ChatViewModel extends StateNotifier<ChatState> {
  final String sessionId;
  final SendMessageUseCase sendMessageUseCase;
  final SendMessageWithImageUseCase sendMessageWithImageUseCase;
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final Uuid uuid;

  ChatViewModel({
    required this.sessionId,
    required this.sendMessageUseCase,
    required this.sendMessageWithImageUseCase,
    required this.getChatHistoryUseCase,
    required this.uuid,
  }) : super(const ChatState()) {
    loadChatHistory();
  }

  /// Load chat history from database
  Future<void> loadChatHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await getChatHistoryUseCase(sessionId);

      result.fold(
        (failure) {
          Logger.error('Failed to load chat history', error: failure.message);
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (messages) {
          Logger.info('Loaded ${messages.length} messages');
          state = state.copyWith(
            isLoading: false,
            messages: messages,
          );
        },
      );
    } catch (e) {
      Logger.error('Error loading chat history', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'চ্যাট ইতিহাস লোড করতে ব্যর্থ',
      );
    }
  }

  /// Send text message
  Future<void> sendMessage({
    required String userId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    state = state.copyWith(isSending: true);

    try {
      final result = await sendMessageUseCase(
        userId: userId,
        sessionId: sessionId,
        message: message.trim(),
      );

      result.fold(
        (failure) {
          Logger.error('Failed to send message', error: failure.message);
          state = state.copyWith(
            isSending: false,
            errorMessage: failure.message,
          );
        },
        (aiMessage) {
          Logger.info('Message sent and response received');
          // Reload chat history to show both user and AI messages
          loadChatHistory();
          state = state.copyWith(isSending: false);
        },
      );
    } catch (e) {
      Logger.error('Error sending message', error: e);
      state = state.copyWith(
        isSending: false,
        errorMessage: 'বার্তা পাঠাতে ব্যর্থ হয়েছে',
      );
    }
  }

  /// Send message with image
  Future<void> sendMessageWithImage({
    required String userId,
    required String message,
    required String imagePath,
  }) async {
    if (message.trim().isEmpty && imagePath.isEmpty) return;

    state = state.copyWith(isSending: true);

    try {
      final result = await sendMessageWithImageUseCase(
        userId: userId,
        sessionId: sessionId,
        message: message.trim().isEmpty ? 'এই ছবিটি দেখুন' : message.trim(),
        imagePath: imagePath,
      );

      result.fold(
        (failure) {
          Logger.error('Failed to send message with image', error: failure.message);
          state = state.copyWith(
            isSending: false,
            errorMessage: failure.message,
          );
        },
        (aiMessage) {
          Logger.info('Message with image sent and response received');
          // Reload chat history and clear selected image
          loadChatHistory();
          state = state.copyWith(isSending: false, clearImage: true);
        },
      );
    } catch (e) {
      Logger.error('Error sending message with image', error: e);
      state = state.copyWith(
        isSending: false,
        errorMessage: 'ছবি সহ বার্তা পাঠাতে ব্যর্থ হয়েছে',
      );
    }
  }

  /// Set selected image
  void setSelectedImage(String? imagePath) {
    state = state.copyWith(
      selectedImagePath: imagePath,
      clearImage: imagePath == null,
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
