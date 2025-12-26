import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/supabase_providers.dart';
import '../../data/repositories/forum_repository_impl.dart';
import '../../domain/repositories/forum_repository.dart';
import '../../domain/usecases/add_post_usecase.dart';
import '../../domain/usecases/get_all_posts_usecase.dart';
import 'forum_state.dart';
import 'forum_view_model.dart';

final forumUuidProvider = Provider<Uuid>((ref) => const Uuid());

final forumRepositoryProvider = Provider<ForumRepository>((ref) {
  return ForumRepositoryImpl(
    databaseService: ref.read(databaseServiceProvider),
    supabaseService: ref.read(supabaseServiceProvider),
    uuid: ref.read(forumUuidProvider),
  );
});

final getAllPostsUseCaseProvider = Provider<GetAllPostsUseCase>(
  (ref) => GetAllPostsUseCase(ref.read(forumRepositoryProvider)),
);

final addPostUseCaseProvider = Provider<AddPostUseCase>(
  (ref) => AddPostUseCase(ref.read(forumRepositoryProvider)),
);

final forumViewModelProvider = StateNotifierProvider<ForumViewModel, ForumState>((ref) {
  return ForumViewModel(
    getAllPostsUseCase: ref.read(getAllPostsUseCaseProvider),
    addPostUseCase: ref.read(addPostUseCaseProvider),
  );
});
