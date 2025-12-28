import 'package:dartz/dartz.dart';
import '../entities/forum_post.dart';
import '../repositories/forum_repository.dart';

class AddPostUseCase {
  final ForumRepository repository;
  
  AddPostUseCase(this.repository);
  
  Future<Either<String, ForumPost>> call({
    required String title,
    required String description,
  }) async {
    return await repository.addPost(
      title: title,
      description: description,
    );
  }
}
