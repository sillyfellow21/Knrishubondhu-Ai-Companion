import 'package:equatable/equatable.dart';

class ForumComment extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ForumComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, postId, userId, userName, content, createdAt, updatedAt];
}
