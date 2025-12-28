import 'package:dartz/dartz.dart';
import '../repositories/forum_repository.dart';

class DeleteCommentUseCase {
  final ForumRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<Either<String, void>> call(String commentId) async {
    return await repository.deleteComment(commentId);
  }
}
