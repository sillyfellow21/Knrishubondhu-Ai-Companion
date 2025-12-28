import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign up with email and password
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  });

  /// Sign in with email and password
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is signed in
  Future<bool> isSignedIn();
}
