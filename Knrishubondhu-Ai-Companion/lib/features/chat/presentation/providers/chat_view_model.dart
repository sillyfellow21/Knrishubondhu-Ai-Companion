import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/chat_message.dart';
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
      sendMessageWithImageUseCase:
          ref.watch(sendMessageWithImageUseCaseProvider),
      getChatHistoryUseCase: ref.watch(getChatHistoryUseCaseProvider),
      uuid: ref.watch(chatUuidProvider),
    );
  },
);

/// Chat View Model
/// Messages are stored in-memory only (not persisted to database)
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
    // Add welcome message on initialization
    _addWelcomeMessage();
  }

  /// Add welcome message from AI
  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: uuid.v4(),
      userId: 'system',
      sessionId: sessionId,
      message:
          ' \n\nআমি কৃষিবন্ধু 🌾 - আপনার বিশ্বস্ত কৃষি পরামর্শদাতা।\n\nআপনি আমাকে যেকোনো কৃষি বিষয়ে প্রশ্ন করতে পারেন:\n• ফসলের রোগ ও পোকামাকড় দমন\n• সার ও কীটনাশক ব্যবহার\n• আধুনিক চাষাবাদ পদ্ধতি\n• ফসলের ছবি বিশ্লেষণ\n\nকীভাবে সাহায্য করতে পারি?',
      sender: 'ai',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(messages: [welcomeMessage]);
    Logger.info('Welcome message added');
  }

  /// Load chat history (no-op for in-memory storage)
  Future<void> loadChatHistory() async {
    // Messages are in-memory only, nothing to load
    Logger.info('Chat history is in-memory only');
  }

  /// Send text message
  Future<void> sendMessage({
    required String userId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    state = state.copyWith(isSending: true, errorMessage: null);

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
        (messages) {
          final (userMessage, aiMessage) = messages;
          Logger.info('Message sent and response received');

          // Add both messages to the state
          final updatedMessages = [...state.messages, userMessage, aiMessage];
          state = state.copyWith(
            isSending: false,
            messages: updatedMessages,
          );
        },
      );
    } catch (e) {
      Logger.error('Error sending message', error: e);
      state = state.copyWith(
        isSending: false,
        errorMessage:
            'বার্তা পাঠাতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
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

    state = state.copyWith(isSending: true, errorMessage: null);

    try {
      final result = await sendMessageWithImageUseCase(
        userId: userId,
        sessionId: sessionId,
        message:
            message.trim().isEmpty ? 'এই ছবিটি বিশ্লেষণ করুন' : message.trim(),
        imagePath: imagePath,
      );

      result.fold(
        (failure) {
          Logger.error('Failed to send message with image',
              error: failure.message);
          state = state.copyWith(
            isSending: false,
            errorMessage: failure.message,
          );
        },
        (messages) {
          final (userMessage, aiMessage) = messages;
          Logger.info('Message with image sent and response received');

          // Add both messages to the state and clear selected image
          final updatedMessages = [...state.messages, userMessage, aiMessage];
          state = state.copyWith(
            isSending: false,
            messages: updatedMessages,
            clearImage: true,
          );
        },
      );
    } catch (e) {
      Logger.error('Error sending message with image', error: e);
      state = state.copyWith(
        isSending: false,
        errorMessage:
            'ছবি সহ বার্তা পাঠাতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
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

  /// Clear all chat messages and start fresh
  void clearChat() {
    _addWelcomeMessage();
    Logger.info('Chat cleared');
  }
}
