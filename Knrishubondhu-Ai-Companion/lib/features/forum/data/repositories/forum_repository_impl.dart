import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/forum_comment.dart';
import '../../domain/entities/forum_post.dart';
import '../../domain/repositories/forum_repository.dart';
import '../models/forum_comment_model.dart';
import '../models/forum_post_model.dart';

class ForumRepositoryImpl implements ForumRepository {
  final SupabaseService supabaseService;
  final Uuid uuid;

  ForumRepositoryImpl({
    required this.supabaseService,
    required this.uuid,
  });

  @override
  String? getCurrentUserId() {
    return supabaseService.auth.currentUser?.id;
  }

  @override
  Future<Either<String, List<ForumPost>>> getAllPosts() async {
    try {
      final user = supabaseService.auth.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করেননি');
      }

      final response = await supabaseService.client
          .from('forum_posts')
          .select()
          .order('created_at', ascending: false);

      final posts = (response as List)
          .map((json) => ForumPostModel.fromSupabase(json))
          .toList();

      return Right(posts);
    } catch (e) {
      Logger.error('Error fetching posts from Supabase: $e');
      return const Left('পোস্ট লোড করতে ব্যর্থ হয়েছে');
    }
  }

  @override
  Future<Either<String, ForumPost>> addPost({
    required String title,
    required String description,
  }) async {
    try {
      final user = supabaseService.auth.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করেননি');
      }

      // Get user name from profile in Supabase
      String userName = 'নাম নেই';
      try {
        final profileResponse = await supabaseService.client
            .from('profiles')
            .select('full_name')
            .eq('user_id', user.id)
            .single();
        userName = profileResponse['full_name'] as String? ?? 'নাম নেই';
      } catch (e) {
        Logger.warning('Could not fetch user profile name: $e');
        // Use email as fallback
        userName = user.email?.split('@').first ?? 'নাম নেই';
      }

      final now = DateTime.now();
      final post = ForumPostModel(
        id: uuid.v4(),
        userId: user.id,
        userName: userName,
        title: title,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      await supabaseService.client
          .from('forum_posts')
          .insert(post.toSupabase());

      return Right(post);
    } catch (e) {
      Logger.error('Error in addPost: $e');
      return const Left('পোস্ট যোগ করতে ব্যর্থ হয়েছে');
    }
  }

  @override
  Future<Either<String, void>> deletePost(String postId) async {
    try {
      final user = supabaseService.auth.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করেননি');
      }

      // RLS will ensure only owner can delete
      await supabaseService.client
          .from('forum_posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', user.id);

      return const Right(null);
    } catch (e) {
      Logger.error('Error in deletePost: $e');
      return const Left('পোস্ট মুছে ফেলতে ব্যর্থ হয়েছে');
    }
  }

  @override
  Future<Either<String, List<ForumComment>>> getComments(String postId) async {
    try {
      final user = supabaseService.auth.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করেননি');
      }

      final response = await supabaseService.client
          .from('forum_comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final comments = (response as List)
          .map((json) => ForumCommentModel.fromSupabase(json))
          .toList();

      return Right(comments);
    } catch (e) {
      Logger.error('Error fetching comments: $e');
      return const Left('মন্তব্য লোড করতে ব্যর্থ হয়েছে');
    }
  }

  @override
  Future<Either<String, ForumComment>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final user = supabaseService.auth.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করেননি');
      }

      // Get user name from profile in Supabase
      String userName = 'নাম নেই';
      try {
        final profileResponse = await supabaseService.client
            .from('profiles')
            .select('full_name')
            .eq('user_id', user.id)
            .single();
        userName = profileResponse['full_name'] as String? ?? 'নাম নেই';
      } catch (e) {
        Logger.warning('Could not fetch user profile name: $e');
        userName = user.email?.split('@').first ?? 'নাম নেই';
      }

      final now = DateTime.now();
      final comment = ForumCommentModel(
        id: uuid.v4(),
        postId: postId,
        userId: user.id,
        userName: userName,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      await supabaseService.client
          .from('forum_comments')
          .insert(comment.toSupabase());

      return Right(comment);
    } catch (e) {
      Logger.error('Error in addComment: $e');
      return const Left('মন্তব্য যোগ করতে ব্যর্থ হয়েছে');
    }
  }

  @override
  Future<Either<String, void>> deleteComment(String commentId) async {
    try {
      final user = supabaseService.auth.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করেননি');
      }

      // RLS will ensure only owner can delete
      await supabaseService.client
          .from('forum_comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', user.id);

      return const Right(null);
    } catch (e) {
      Logger.error('Error in deleteComment: $e');
      return const Left('মন্তব্য মুছে ফেলতে ব্যর্থ হয়েছে');
    }
  }
}
