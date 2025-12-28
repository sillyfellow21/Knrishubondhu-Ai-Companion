import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/forum_post.dart';
import '../../domain/repositories/forum_repository.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/add_post_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../../domain/usecases/get_all_posts_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import 'forum_state.dart';

class ForumViewModel extends StateNotifier<ForumState> {
  final GetAllPostsUseCase getAllPostsUseCase;
  final AddPostUseCase addPostUseCase;
  final DeletePostUseCase deletePostUseCase;
  final ForumRepository repository;

  ForumViewModel({
    required this.getAllPostsUseCase,
    required this.addPostUseCase,
    required this.deletePostUseCase,
    required this.repository,
  }) : super(const ForumInitial());

  Future<void> loadPosts() async {
    state = const ForumLoading();
    try {
      final result = await getAllPostsUseCase.call();
      final currentUserId = repository.getCurrentUserId();
      result.fold(
        (error) => state = ForumError(error),
        (posts) => state = posts.isEmpty
            ? const ForumEmpty()
            : ForumLoaded(posts, currentUserId: currentUserId),
      );
    } catch (e) {
      state = const ForumError('পোস্ট লোড করতে ব্যর্থ হয়েছে।');
    }
  }

  Future<bool> addPost({
    required String title,
    required String description,
  }) async {
    try {
      final result = await addPostUseCase.call(
        title: title,
        description: description,
      );
      return result.fold(
        (error) => false,
        (post) {
          loadPosts();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final result = await deletePostUseCase.call(postId);
      return result.fold(
        (error) => false,
        (_) {
          loadPosts();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> refresh() async => await loadPosts();
}

// ViewModel for post detail with comments
class PostDetailViewModel extends StateNotifier<PostDetailState> {
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final ForumRepository repository;

  ForumPost? _currentPost;

  PostDetailViewModel({
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
    required this.repository,
  }) : super(const PostDetailInitial());

  Future<void> loadPostDetail(ForumPost post) async {
    _currentPost = post;
    state = const PostDetailLoading();
    try {
      final result = await getCommentsUseCase.call(post.id);
      final currentUserId = repository.getCurrentUserId();
      result.fold(
        (error) => state = PostDetailError(error),
        (comments) => state = PostDetailLoaded(
          post: post,
          comments: comments,
          currentUserId: currentUserId,
        ),
      );
    } catch (e) {
      state = const PostDetailError('মন্তব্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }

  Future<bool> addComment(String content) async {
    if (_currentPost == null) return false;
    try {
      final result = await addCommentUseCase.call(
        postId: _currentPost!.id,
        content: content,
      );
      return result.fold(
        (error) => false,
        (comment) {
          loadPostDetail(_currentPost!);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    if (_currentPost == null) return false;
    try {
      final result = await deleteCommentUseCase.call(commentId);
      return result.fold(
        (error) => false,
        (_) {
          loadPostDetail(_currentPost!);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> refresh() async {
    if (_currentPost != null) {
      await loadPostDetail(_currentPost!);
    }
  }
}
