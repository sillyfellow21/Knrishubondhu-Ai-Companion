import 'package:dartz/dartz.dart';
import '../repositories/land_repository.dart';

/// Use case for deleting a land
class DeleteLandUseCase {
  final LandRepository repository;
  
  DeleteLandUseCase(this.repository);
  
  Future<Either<String, void>> call(String landId) async {
    return await repository.deleteLand(landId);
  }
}
