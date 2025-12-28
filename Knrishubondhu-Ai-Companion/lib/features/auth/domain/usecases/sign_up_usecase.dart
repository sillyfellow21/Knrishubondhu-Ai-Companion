import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }
}
