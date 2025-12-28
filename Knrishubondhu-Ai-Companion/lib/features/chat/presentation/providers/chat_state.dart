import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

/// Chat State
class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final String? selectedImagePath;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.selectedImagePath,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    String? selectedImagePath,
    bool clearImage = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
      selectedImagePath: clearImage ? null : (selectedImagePath ?? this.selectedImagePath),
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        isSending,
        errorMessage,
        selectedImagePath,
      ];
}
