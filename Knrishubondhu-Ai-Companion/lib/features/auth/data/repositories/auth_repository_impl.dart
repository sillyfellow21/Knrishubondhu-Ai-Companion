import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService supabaseService;
  final DatabaseService databaseService;

  AuthRepositoryImpl({
    required this.supabaseService,
    required this.databaseService,
  });

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      Logger.info('Signing up user: $email');

      final response = await supabaseService.signUpWithEmail(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'role': 'farmer',
        },
      );

      if (response.user == null) {
        return const Left(AuthFailure('সাইন আপ ব্যর্থ হয়েছে'));
      }

      final user = UserModel.fromSupabaseUser(response.user!);

      // Save to local database
      await databaseService.insertUser(user.toDatabase());

      Logger.info('User signed up successfully: ${user.email}');
      return Right(user);
    } on AuthException catch (e) {
      Logger.error('Auth exception during sign up', error: e);
      return Left(AuthFailure(_getAuthErrorMessage(e.message)));
    } catch (e) {
      Logger.error('Unexpected error during sign up', error: e);
      return const Left(AuthFailure('কিছু ভুল হয়েছে। আবার চেষ্টা করুন।'));
    }
  }

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('Signing in user: $email');

      final response = await supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(AuthFailure('লগইন ব্যর্থ হয়েছে'));
      }

      final user = UserModel.fromSupabaseUser(response.user!);

      // Save/update in local database
      final existingUser = await databaseService.getUserBySupabaseId(user.id);
      if (existingUser == null) {
        await databaseService.insertUser(user.toDatabase());
      } else {
        await databaseService.updateUser(
          existingUser['id'] as String,
          user.toDatabase(),
        );
      }

      Logger.info('User signed in successfully: ${user.email}');
      return Right(user);
    } on AuthException catch (e) {
      Logger.error('Auth exception during sign in', error: e);
      return Left(AuthFailure(_getAuthErrorMessage(e.message)));
    } catch (e) {
      Logger.error('Unexpected error during sign in', error: e);
      return const Left(AuthFailure('কিছু ভুল হয়েছে। আবার চেষ্টা করুন।'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      Logger.info('Signing out user');
      await supabaseService.signOut();
      Logger.info('User signed out successfully');
      return const Right(null);
    } catch (e) {
      Logger.error('Error during sign out', error: e);
      return const Left(AuthFailure('সাইন আউট ব্যর্থ হয়েছে'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final currentUser = supabaseService.currentUser;

      if (currentUser == null) {
        return const Right(null);
      }

      final user = UserModel.fromSupabaseUser(currentUser);
      return Right(user);
    } catch (e) {
      Logger.error('Error getting current user', error: e);
      return const Left(AuthFailure('ব্যবহারকারী তথ্য পেতে ব্যর্থ'));
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return supabaseService.isSignedIn;
  }

  String _getAuthErrorMessage(String error) {
    if (error.toLowerCase().contains('email') && error.toLowerCase().contains('already')) {
      return 'এই ইমেইল ইতিমধ্যে নিবন্ধিত আছে';
    } else if (error.toLowerCase().contains('invalid') && error.toLowerCase().contains('credentials')) {
      return 'ইমেইল বা পাসওয়ার্ড ভুল হয়েছে';
    } else if (error.toLowerCase().contains('password')) {
      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
    } else if (error.toLowerCase().contains('email') && error.toLowerCase().contains('invalid')) {
      return 'সঠিক ইমেইল ঠিকানা দিন';
    } else if (error.toLowerCase().contains('network')) {
      return 'ইন্টারনেট সংযোগ নেই';
    } else {
      return 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।';
    }
  }
}
