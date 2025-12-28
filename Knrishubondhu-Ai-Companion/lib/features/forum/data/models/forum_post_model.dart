import '../../domain/entities/forum_post.dart';

class ForumPostModel extends ForumPost {
  const ForumPostModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ForumPostModel.fromSupabase(Map<String, dynamic> json) {
    return ForumPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
