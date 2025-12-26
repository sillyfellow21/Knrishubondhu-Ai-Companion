import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/add_post_usecase.dart';
import '../../domain/usecases/get_all_posts_usecase.dart';
import 'forum_state.dart';

class ForumViewModel extends StateNotifier<ForumState> {
  final GetAllPostsUseCase getAllPostsUseCase;
  final AddPostUseCase addPostUseCase;
  
  ForumViewModel({
    required this.getAllPostsUseCase,
    required this.addPostUseCase,
  }) : super(const ForumInitial());
  
  Future<void> loadPosts() async {
    state = const ForumLoading();
    try {
      final result = await getAllPostsUseCase.call();
      result.fold(
        (error) => state = ForumError(error),
        (posts) => state = posts.isEmpty ? const ForumEmpty() : ForumLoaded(posts),
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
  
  Future<void> refresh() async => await loadPosts();
}
