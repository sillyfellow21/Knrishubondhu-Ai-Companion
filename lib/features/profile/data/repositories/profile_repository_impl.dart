import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseService supabaseService;
  final DatabaseService databaseService;
  final Uuid uuid;

  ProfileRepositoryImpl({
    required this.supabaseService,
    required this.databaseService,
    required this.uuid,
  });

  @override
  Future<Either<Failure, UserProfile>> saveProfile({
    required String userId,
    required String fullName,
    required String area,
    required double landAmount,
  }) async {
    try {
      Logger.info('Saving profile for user: $userId');

      final now = DateTime.now();
      final profileId = uuid.v4();

      final profile = UserProfileModel(
        id: profileId,
        userId: userId,
        fullName: fullName,
        area: area,
        landAmount: landAmount,
        createdAt: now,
        updatedAt: now,
      );

      // Save to local database first (always works)
      final db = await databaseService.database;
      await db.insert(
        'user_profiles',
        profile.toDatabase(),
      );

      Logger.info('Profile saved to local database');

      // Try to sync to Supabase (non-blocking)
      try {
        final supabaseData = {
          'user_id': userId,
          'full_name': fullName,
          'area': area,
          'land_amount': landAmount,
        };

        await supabaseService.insert(
          table: 'profiles',
          data: supabaseData,
        );
        
        Logger.info('Profile synced to Supabase');
      } catch (supabaseError) {
        // Log error but don't fail the operation
        Logger.warning('Supabase sync failed (profile saved locally): $supabaseError');
      }

      Logger.info('Profile saved successfully for user: $userId');
      return Right(profile);
    } on DatabaseException catch (e) {
      Logger.error('Database exception during save profile', error: e);
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      Logger.error('Unexpected error during save profile', error: e);
      return Left(ServerFailure('প্রোফাইল সংরক্ষণ ব্যর্থ হয়েছে: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getProfile(String userId) async {
    try {
      Logger.info('Getting profile for user: $userId');

      // Try to get from local database first
      final localProfile = await databaseService.queryOne(
        table: 'user_profiles',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (localProfile != null) {
        Logger.info('Profile found in local database');
        return Right(UserProfileModel.fromDatabase(localProfile));
      }

      // If not found locally, fetch from Supabase
      final response = await supabaseService.from('profiles').select().eq('user_id', userId);

      if (response.isEmpty) {
        Logger.info('No profile found for user: $userId');
        return const Right(null);
      }

      final profile = UserProfileModel.fromJson(response.first);

      // Save to local database
      await databaseService.insert(
        table: 'user_profiles',
        data: profile.toDatabase(),
      );

      Logger.info('Profile fetched from Supabase and saved locally');
      return Right(profile);
    } on DatabaseException catch (e) {
      Logger.error('Database exception during get profile', error: e);
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      Logger.error('Unexpected error during get profile', error: e);
      return const Left(ServerFailure('প্রোফাইল লোড করতে ব্যর্থ'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String profileId,
    required String fullName,
    required String area,
    required double landAmount,
  }) async {
    try {
      Logger.info('Updating profile: $profileId');

      final now = DateTime.now();
      final updateData = {
        'full_name': fullName,
        'area': area,
        'land_amount': landAmount,
        'updated_at': now.toIso8601String(),
      };

      // Update in Supabase
      final response = await supabaseService.update(
        table: 'profiles',
        data: updateData,
        matchColumn: 'id',
        matchValue: profileId,
      );

      if (response.isEmpty) {
        return const Left(ServerFailure('প্রোফাইল আপডেট ব্যর্থ হয়েছে'));
      }

      final profile = UserProfileModel.fromJson(response.first);

      // Update in local database
      await databaseService.update(
        table: 'user_profiles',
        data: profile.toDatabase(),
        where: 'id = ?',
        whereArgs: [profileId],
      );

      Logger.info('Profile updated successfully: $profileId');
      return Right(profile);
    } on DatabaseException catch (e) {
      Logger.error('Database exception during update profile', error: e);
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      Logger.error('Unexpected error during update profile', error: e);
      return const Left(ServerFailure('কিছু ভুল হয়েছে। আবার চেষ্টা করুন।'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile(String profileId) async {
    try {
      Logger.info('Deleting profile: $profileId');

      // Delete from Supabase
      await supabaseService.delete(
        table: 'profiles',
        matchColumn: 'id',
        matchValue: profileId,
      );

      // Delete from local database
      await databaseService.delete(
        table: 'user_profiles',
        where: 'id = ?',
        whereArgs: [profileId],
      );

      Logger.info('Profile deleted successfully: $profileId');
      return const Right(null);
    } catch (e) {
      Logger.error('Error during delete profile', error: e);
      return const Left(ServerFailure('প্রোফাইল মুছতে ব্যর্থ'));
    }
  }
}
