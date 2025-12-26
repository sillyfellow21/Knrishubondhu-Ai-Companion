import 'package:dartz/dartz.dart';
import '../entities/forum_post.dart';

abstract class ForumRepository {
  Future<Either<String, List<ForumPost>>> getAllPosts();
  Future<Either<String, ForumPost>> addPost({
    required String title,
    required String description,
  });
}
