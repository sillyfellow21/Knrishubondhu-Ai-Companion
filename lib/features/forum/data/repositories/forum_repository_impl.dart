import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/forum_post.dart';
import '../../domain/repositories/forum_repository.dart';
import '../models/forum_post_model.dart';

class ForumRepositoryImpl implements ForumRepository {
  final DatabaseService databaseService;
  final SupabaseService supabaseService;
  final Uuid uuid;
  
  ForumRepositoryImpl({
    required this.databaseService,
    required this.supabaseService,
    required this.uuid,
  });
  
  @override
  Future<Either<String, List<ForumPost>>> getAllPosts() async {
    try {
      // Try to fetch from Supabase first
      final user = supabaseService.auth.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করেননি');
      }
      
      try {
        final response = await supabaseService.client
            .from('forum_posts')
            .select()
            .order('created_at', ascending: false);
        
        final posts = (response as List)
            .map((json) => ForumPostModel.fromSupabase(json))
            .toList();
        
        // Cache the posts
        await _cachePosts(posts);
        
        return Right(posts);
      } catch (e) {
        Logger.error('Error fetching posts from Supabase: $e');
        // Fall back to cache
        return _getPostsFromCache();
      }
    } catch (e) {
      Logger.error('Error in getAllPosts: $e');
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
      
      // Get user name from profile
      final db = await databaseService.database;
      final userProfile = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [user.id],
        limit: 1,
      );
      
      final userName = userProfile.isNotEmpty
          ? userProfile.first['name'] as String
          : 'নাম নেই';
      
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
      
      // Insert to Supabase
      try {
        await supabaseService.client
            .from('forum_posts')
            .insert(post.toSupabase());
      } catch (e) {
        Logger.error('Error inserting post to Supabase: $e');
        return const Left('পোস্ট যোগ করতে ব্যর্থ হয়েছে');
      }
      
      // Cache the post
      await _cachePost(post);
      
      return Right(post);
    } catch (e) {
      Logger.error('Error in addPost: $e');
      return const Left('পোস্ট যোগ করতে ব্যর্থ হয়েছে');
    }
  }
  
  Future<void> _cachePosts(List<ForumPostModel> posts) async {
    try {
      final db = await databaseService.database;
      
      // Clear old cache
      await db.delete('forum_posts_cache');
      
      // Insert new cache
      for (final post in posts) {
        await db.insert('forum_posts_cache', post.toCache());
      }
    } catch (e) {
      Logger.error('Error caching posts: $e');
    }
  }
  
  Future<void> _cachePost(ForumPostModel post) async {
    try {
      final db = await databaseService.database;
      await db.insert('forum_posts_cache', post.toCache());
    } catch (e) {
      Logger.error('Error caching post: $e');
    }
  }
  
  Future<Either<String, List<ForumPost>>> _getPostsFromCache() async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'forum_posts_cache',
        orderBy: 'created_at DESC',
      );
      
      final posts = results
          .map((json) => ForumPostModel.fromCache(json))
          .toList();
      
      return Right(posts);
    } catch (e) {
      Logger.error('Error reading posts from cache: $e');
      return const Left('ক্যাশ থেকে পোস্ট লোড করতে ব্যর্থ হয়েছে');
    }
  }
}
