import 'package:dartz/dartz.dart';
import '../entities/forum_comment.dart';
import '../entities/forum_post.dart';

abstract class ForumRepository {
  /// Get all forum posts
  Future<Either<String, List<ForumPost>>> getAllPosts();

  /// Add a new post
  Future<Either<String, ForumPost>> addPost({
    required String title,
    required String description,
  });

  /// Delete a post (only owner can delete)
  Future<Either<String, void>> deletePost(String postId);

  /// Get comments for a specific post
  Future<Either<String, List<ForumComment>>> getComments(String postId);

  /// Add a comment to a post
  Future<Either<String, ForumComment>> addComment({
    required String postId,
    required String content,
  });

  /// Delete a comment (only owner can delete)
  Future<Either<String, void>> deleteComment(String commentId);

  /// Get current user ID
  String? getCurrentUserId();
}
