import '../../domain/entities/forum_comment.dart';

class ForumCommentModel extends ForumComment {
  const ForumCommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.userName,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ForumCommentModel.fromSupabase(Map<String, dynamic> json) {
    return ForumCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
