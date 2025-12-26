import 'package:equatable/equatable.dart';

/// Chat Message entity
class ChatMessage extends Equatable {
  final String id;
  final String userId;
  final String sessionId;
  final String message;
  final String sender; // 'user' or 'ai'
  final String? imagePath;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.message,
    required this.sender,
    this.imagePath,
    required this.createdAt,
  });

  bool get isUser => sender == 'user';
  bool get isAI => sender == 'ai';
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        sessionId,
        message,
        sender,
        imagePath,
        createdAt,
      ];
}
