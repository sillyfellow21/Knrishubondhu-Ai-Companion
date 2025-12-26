import 'package:dartz/dartz.dart';
import '../entities/forum_post.dart';
import '../repositories/forum_repository.dart';

class GetAllPostsUseCase {
  final ForumRepository repository;
  
  GetAllPostsUseCase(this.repository);
  
  Future<Either<String, List<ForumPost>>> call() async {
    return await repository.getAllPosts();
  }
}
