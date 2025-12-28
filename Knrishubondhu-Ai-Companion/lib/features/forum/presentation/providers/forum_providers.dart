import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/supabase_providers.dart';
import '../../data/repositories/forum_repository_impl.dart';
import '../../domain/repositories/forum_repository.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/add_post_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../../domain/usecases/get_all_posts_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import 'forum_state.dart';
import 'forum_view_model.dart';

final forumUuidProvider = Provider<Uuid>((ref) => const Uuid());

final forumRepositoryProvider = Provider<ForumRepository>((ref) {
  return ForumRepositoryImpl(
    supabaseService: ref.read(supabaseServiceProvider),
    uuid: ref.read(forumUuidProvider),
  );
});

// Post use cases
final getAllPostsUseCaseProvider = Provider<GetAllPostsUseCase>(
  (ref) => GetAllPostsUseCase(ref.read(forumRepositoryProvider)),
);

final addPostUseCaseProvider = Provider<AddPostUseCase>(
  (ref) => AddPostUseCase(ref.read(forumRepositoryProvider)),
);

final deletePostUseCaseProvider = Provider<DeletePostUseCase>(
  (ref) => DeletePostUseCase(ref.read(forumRepositoryProvider)),
);

// Comment use cases
final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>(
  (ref) => GetCommentsUseCase(ref.read(forumRepositoryProvider)),
);

final addCommentUseCaseProvider = Provider<AddCommentUseCase>(
  (ref) => AddCommentUseCase(ref.read(forumRepositoryProvider)),
);

final deleteCommentUseCaseProvider = Provider<DeleteCommentUseCase>(
  (ref) => DeleteCommentUseCase(ref.read(forumRepositoryProvider)),
);

// View models
final forumViewModelProvider =
    StateNotifierProvider<ForumViewModel, ForumState>((ref) {
  return ForumViewModel(
    getAllPostsUseCase: ref.read(getAllPostsUseCaseProvider),
    addPostUseCase: ref.read(addPostUseCaseProvider),
    deletePostUseCase: ref.read(deletePostUseCaseProvider),
    repository: ref.read(forumRepositoryProvider),
  );
});

final postDetailViewModelProvider =
    StateNotifierProvider<PostDetailViewModel, PostDetailState>((ref) {
  return PostDetailViewModel(
    getCommentsUseCase: ref.read(getCommentsUseCaseProvider),
    addCommentUseCase: ref.read(addCommentUseCaseProvider),
    deleteCommentUseCase: ref.read(deleteCommentUseCaseProvider),
    repository: ref.read(forumRepositoryProvider),
  );
});
