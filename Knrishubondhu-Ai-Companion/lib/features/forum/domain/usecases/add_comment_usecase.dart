import 'package:dartz/dartz.dart';
import '../entities/forum_comment.dart';
import '../repositories/forum_repository.dart';

class AddCommentUseCase {
  final ForumRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<String, ForumComment>> call({
    required String postId,
    required String content,
  }) async {
    return await repository.addComment(
      postId: postId,
      content: content,
    );
  }
}
