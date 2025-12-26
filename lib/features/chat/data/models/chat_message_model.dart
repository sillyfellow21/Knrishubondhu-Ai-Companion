import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.userId,
    required super.sessionId,
    required super.message,
    required super.sender,
    super.imagePath,
    required super.createdAt,
  });

  factory ChatMessageModel.fromDatabase(Map<String, dynamic> db) {
    return ChatMessageModel(
      id: db['id'] as String,
      userId: db['user_id'] as String,
      sessionId: db['session_id'] as String,
      message: db['message'] as String,
      sender: db['sender'] as String,
      imagePath: db['metadata'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(db['created_at'] as int),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'message': message,
      'sender': sender,
      'message_type': hasImage ? 'image' : 'text',
      'metadata': imagePath,
      'is_synced': 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
