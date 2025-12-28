import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUseCase {
  final ProfileRepository repository;

  SaveProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call({
    required String userId,
    required String fullName,
    required String area,
    required double landAmount,
  }) async {
    return await repository.saveProfile(
      userId: userId,
      fullName: fullName,
      area: area,
      landAmount: landAmount,
    );
  }
}
