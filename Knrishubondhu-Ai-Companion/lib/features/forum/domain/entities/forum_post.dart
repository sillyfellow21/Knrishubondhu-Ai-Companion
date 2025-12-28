import 'package:equatable/equatable.dart';

class ForumPost extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ForumPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [id, userId, userName, title, description, createdAt, updatedAt];
}
