import 'package:dartz/dartz.dart';
import '../entities/forum_comment.dart';
import '../repositories/forum_repository.dart';

class GetCommentsUseCase {
  final ForumRepository repository;

  GetCommentsUseCase(this.repository);

  Future<Either<String, List<ForumComment>>> call(String postId) async {
    return await repository.getComments(postId);
  }
}
