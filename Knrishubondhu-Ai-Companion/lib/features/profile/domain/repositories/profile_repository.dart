import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Create or update user profile
  Future<Either<Failure, UserProfile>> saveProfile({
    required String userId,
    required String fullName,
    required String area,
    required double landAmount,
  });

  /// Get user profile by user ID
  Future<Either<Failure, UserProfile?>> getProfile(String userId);

  /// Update user profile
  Future<Either<Failure, UserProfile>> updateProfile({
    required String profileId,
    required String fullName,
    required String area,
    required double landAmount,
  });

  /// Delete user profile
  Future<Either<Failure, void>> deleteProfile(String profileId);
}
