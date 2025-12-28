import 'package:dartz/dartz.dart';
import '../repositories/forum_repository.dart';

class DeletePostUseCase {
  final ForumRepository repository;

  DeletePostUseCase(this.repository);

  Future<Either<String, void>> call(String postId) async {
    return await repository.deletePost(postId);
  }
}
